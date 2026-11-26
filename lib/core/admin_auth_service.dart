import 'package:supabase_flutter/supabase_flutter.dart';

import 'session_manager.dart';

class AdminAuthException implements Exception {
  const AdminAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AdminLoginResult {
  const AdminLoginResult({required this.accessToken, this.refreshToken});
  final String accessToken;
  final String? refreshToken;
}

class AdminProfile {
  const AdminProfile({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phone,
  });

  final int id;
  final String username;
  final String fullName;
  final String email;
  final String? phone;

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    final id = json['id_admin'];
    if (id is! num ||
        json['username'] is! String ||
        json['nama_lengkap_admin'] is! String ||
        json['email'] is! String) {
      throw const FormatException('Data profil admin tidak lengkap.');
    }
    return AdminProfile(
      id: id.toInt(),
      username: json['username'] as String,
      fullName: json['nama_lengkap_admin'] as String,
      email: json['email'] as String,
      phone: json['no_telephone'] as String?,
    );
  }
}

class AdminActivity {
  const AdminActivity({
    required this.action,
    required this.table,
    required this.createdAt,
    this.targetId,
  });
  final String action;
  final String table;
  final DateTime createdAt;
  final String? targetId;

  factory AdminActivity.fromJson(Map<String, dynamic> json) {
    final createdAt = json['dibuat_pada'];
    if (json['aksi'] is! String ||
        json['target_tabel'] is! String ||
        createdAt is! String) {
      throw const FormatException('Data aktivitas admin tidak valid.');
    }
    final date = DateTime.tryParse(createdAt);
    if (date == null) {
      throw const FormatException('Waktu aktivitas admin tidak valid.');
    }
    return AdminActivity(
      action: json['aksi'] as String,
      table: json['target_tabel'] as String,
      targetId: json['target_id'] as String?,
      createdAt: date.toLocal(),
    );
  }
}

class AdminAuthService {
  static SupabaseClient get _db => Supabase.instance.client;
  static String? get _authId => _db.auth.currentUser?.id;

  static Never _fail(Object error) {
    if (error is AdminAuthException) throw error;
    if (error is AuthException) throw AdminAuthException(error.message);
    if (error is PostgrestException) throw AdminAuthException(error.message);
    throw AdminAuthException(error.toString());
  }

  static Future<AdminLoginResult> login({
    required String username,
    required String password,
  }) async {
    if (!username.contains('@')) {
      throw const AdminAuthException(
        'Login admin sekarang memakai alamat email.',
      );
    }
    try {
      final response = await _db.auth.signInWithPassword(
        email: username.trim(),
        password: password,
      );
      final session = response.session;
      if (response.user == null || session == null) {
        throw const AdminAuthException('Email atau password admin salah.');
      }
      try {
        await _db
            .from('admin_lokatrip')
            .select('id_admin')
            .eq('auth_id', response.user!.id)
            .single();
      } catch (_) {
        await _db.auth.signOut();
        rethrow;
      }
      return AdminLoginResult(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
    } catch (error) {
      if (error is AdminAuthException) rethrow;
      _fail(error);
    }
  }

  static Future<AdminProfile> getProfile({required String accessToken}) async {
    try {
      final row = await _db
          .from('admin_lokatrip')
          .select('id_admin, username, nama_lengkap_admin, email, no_telephone')
          .eq('auth_id', _authId!)
          .single();
      return AdminProfile.fromJson(row);
    } catch (error) {
      _fail(error);
    }
  }

  static Future<AdminProfile> updateProfile({
    required String accessToken,
    required String username,
    required String fullName,
    required String? phone,
  }) async {
    try {
      final row = await _db
          .from('admin_lokatrip')
          .update({
            'username': username,
            'nama_lengkap_admin': fullName,
            'no_telephone': phone,
          })
          .eq('auth_id', _authId!)
          .select('id_admin, username, nama_lengkap_admin, email, no_telephone')
          .single();
      return AdminProfile.fromJson(row);
    } catch (error) {
      _fail(error);
    }
  }

  static Future<List<AdminActivity>> getRecentActivities({
    required String accessToken,
  }) async {
    try {
      final rows = await _db
          .from('riwayat_aktivitas_admin')
          .select(
            'id_aktivitas_admin, id_admin, aksi, target_tabel, target_id, detail, dibuat_pada, admin_lokatrip(nama_lengkap_admin, email)',
          )
          .order('dibuat_pada', ascending: false)
          .limit(3);
      return (rows as List)
          .whereType<Map<String, dynamic>>()
          .map(AdminActivity.fromJson)
          .toList(growable: false);
    } catch (error) {
      _fail(error);
    }
  }

  static Future<Map<String, dynamic>> getDashboard({
    required String accessToken,
  }) async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 30));
      final mitras = await _db.from('admin_wisata').select('id_mitra');
      final wisata = await _db.from('wisata').select('status_approve');
      final dokumen = await _db
          .from('dokumen')
          .select('status_approve, masa_berlaku_sampai');
      final orders = await _db
          .from('pemesanan')
          .select('id_pemesanan, total_bayar, status_pesan');
      final details = await _db.from('detail_pemesanan').select('jumlah');
      final docs = dokumen as List;
      final paid = (orders as List).where(
        (row) => const {
          'berhasil',
          'dibayar',
          'lunas',
          'paid',
        }.contains('${row['status_pesan']}'.toLowerCase()),
      );
      final expiryRows = docs.where((row) {
        final expiry = DateTime.tryParse('${row['masa_berlaku_sampai'] ?? ''}');
        return row['status_approve'] == 'Y' &&
            expiry != null &&
            !expiry.isBefore(start) &&
            !expiry.isAfter(end);
      });
      return {
        'total_mitra': (mitras as List).length,
        'wisata_aktif': (wisata as List)
            .where((r) => r['status_approve'] == 'Y')
            .length,
        'wisata_menunggu_verifikasi': (wisata)
            .where((r) => r['status_approve'] == 'N')
            .length,
        'dokumen_menunggu_verifikasi': docs
            .where((r) => r['status_approve'] == 'N')
            .length,
        'dokumen_disetujui': docs
            .where((r) => r['status_approve'] == 'Y')
            .length,
        'dokumen_segera_kedaluwarsa': expiryRows.length,
        'dokumen_kedaluwarsa': docs.where((r) {
          final expiry = DateTime.tryParse('${r['masa_berlaku_sampai'] ?? ''}');
          return r['status_approve'] == 'Y' &&
              expiry != null &&
              expiry.isBefore(start);
        }).length,
        'total_pesanan': (orders).length,
        'tiket_terjual': (details as List).fold<int>(
          0,
          (sum, row) => sum + ((row['jumlah'] as num?)?.toInt() ?? 0),
        ),
        'nilai_transaksi_bruto': paid.fold<int>(
          0,
          (sum, row) => sum + ((row['total_bayar'] as num?)?.toInt() ?? 0),
        ),
      };
    } catch (error) {
      _fail(error);
    }
  }

  static Future<List<Map<String, dynamic>>> getMitras({
    required String accessToken,
    String search = '',
  }) async {
    try {
      var query = _db
          .from('admin_wisata')
          .select(
            'id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone, wisata(id_wisata, nama_wisata, lokasi, kota, status_approve, kategori(nama_kategori)), dokumen(id_dokumen, jenis_dokumen, nomor_dokumen, file_dokumen, status_approve, masa_berlaku_sampai), status_mitra_admin(status_mitra, ditampilkan_di_beranda, catatan_admin, diperbarui_pada)',
          );
      if (search.trim().isNotEmpty) {
        final term = search.trim().replaceAll(RegExp(r'[,().]'), ' ');
        query = query.or(
          'username.ilike.%$term%,nama_lengkap_admin.ilike.%$term%,email.ilike.%$term%',
        );
      }
      final rows = await query.order('id_mitra', ascending: false).limit(100);
      return (rows as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    } catch (error) {
      _fail(error);
    }
  }

  static Future<void> provisionMitraAccount({
    required String accessToken,
    required int mitraId,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _db.functions.invoke(
        'smart-endpoint',
        headers: {'Authorization': 'Bearer $accessToken'},
        body: {
          'action': 'provision_mitra_account',
          'id_mitra': mitraId,
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );
      final data = response.data;
      if (data is Map && data['error'] is String) {
        throw AdminAuthException(data['error'] as String);
      }
    } catch (error) {
      _fail(error);
    }
  }

  static Future<Map<String, dynamic>> updateMitraStatus({
    required String accessToken,
    required int id,
    required String status,
    String? note,
    bool? featured,
  }) async {
    try {
      final row = await _db.rpc(
        'admin_set_mitra_status',
        params: {
          'p_id_mitra': id,
          'p_status': status,
          'p_note': note,
          'p_featured': featured,
        },
      );
      return {'data': row};
    } catch (error) {
      _fail(error);
    }
  }

  static Future<List<Map<String, dynamic>>> getDocuments({
    required String accessToken,
    String? status,
  }) async {
    try {
      var query = _db
          .from('dokumen')
          .select(
            'id_dokumen, id_mitra, id_admin, jenis_dokumen, nomor_dokumen, file_dokumen, status_approve, masa_berlaku_sampai, catatan_admin, diperiksa_pada, admin_wisata(id_mitra, username, nama_lengkap_admin, email)',
          );
      if (status != null) query = query.eq('status_approve', status);
      final rows = await query.order('id_dokumen', ascending: false).limit(100);
      return (rows as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    } catch (error) {
      _fail(error);
    }
  }

  static Future<Map<String, dynamic>> decideDocument({
    required String accessToken,
    required int id,
    required String decision,
    String? note,
    String? expiry,
  }) async {
    try {
      final row = await _db.rpc(
        'admin_decide_dokumen',
        params: {
          'p_id_dokumen': id,
          'p_decision': decision,
          'p_note': note,
          'p_expiry': expiry,
        },
      );
      return {'data': row};
    } catch (error) {
      if (error is AdminAuthException) rethrow;
      _fail(error);
    }
  }

  static Future<List<Map<String, dynamic>>> getWisata({
    required String accessToken,
    String? status,
  }) async {
    try {
      var query = _db
          .from('wisata')
          .select(
            'id_wisata, id_mitra, id_kategori, id_admin, nama_wisata, lokasi, kota, deskripsi, jenis, subkategori, rata_rating, jml_ulasan, status_approve, admin_wisata(id_mitra, username, nama_lengkap_admin, email), kategori(id_kategori, nama_kategori), foto_wisata(id_foto, url_foto, urutan)',
          );
      if (status != null) query = query.eq('status_approve', status);
      final rows = await query.order('id_wisata', ascending: false).limit(100);
      return (rows as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    } catch (error) {
      _fail(error);
    }
  }

  static Future<Map<String, dynamic>> decideWisata({
    required String accessToken,
    required int id,
    required String decision,
  }) async {
    try {
      final row = await _db.rpc(
        'admin_decide_wisata',
        params: {'p_id_wisata': id, 'p_decision': decision},
      );
      return {'data': row};
    } catch (error) {
      if (error is AdminAuthException) rethrow;
      _fail(error);
    }
  }

  static Future<void> logout({required String accessToken}) async {
    try {
      await _db.auth.signOut();
      await SessionManager.logout();
    } catch (error) {
      _fail(error);
    }
  }
}
