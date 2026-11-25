import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'session_manager.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

SupabaseClient get _supabase => Supabase.instance.client;

String _phoneForAuth(String value) {
  final phone = value.replaceAll(RegExp(r'[\s\-()]'), '');
  if (phone.startsWith('+')) return phone;
  if (phone.startsWith('62')) return '+$phone';
  if (phone.startsWith('0')) return '+62${phone.substring(1)}';
  return phone;
}

Never _apiError(Object error) {
  if (error is ApiException) throw error;
  if (error is AuthException) throw ApiException(error.message);
  if (error is PostgrestException) throw ApiException(error.message);
  if (error is FunctionException) {
    final details = error.details;
    if (details is Map && details['error'] is String) {
      throw ApiException(details['error'] as String);
    }
    throw ApiException(error.reasonPhrase ?? 'Permintaan gagal.');
  }
  throw ApiException(error.toString());
}

Map<String, dynamic> _map(dynamic value, String message) {
  if (value is Map<String, dynamic>) return value;
  throw ApiException(message);
}

List<Map<String, dynamic>> _rows(dynamic value, String message) {
  if (value is! List) throw ApiException(message);
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}

class UserApi {
  static const _profileColumns =
      'id_user, nama_lengkap_user, username, email, no_telephone, tgl_lahir, jenis_kelamin, foto_profil, total_poin, status_verif';

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      if (identifier.contains('@')) {
        final response = await _supabase.auth.signInWithPassword(
          email: identifier.trim(),
          password: password,
        );
        return _signedInUser(response.user, response.session);
      }

      // The deployed Supabase function keeps legacy LokaTrip phone sign-in
      // working while the app no longer needs its own Express API.
      final response = await _supabase.functions.invoke(
        'smart-endpoint',
        body: {'phone': _phoneForAuth(identifier), 'password': password},
      );
      final payload = _map(response.data, 'Respons login tidak valid.');
      final session = _map(payload['session'], 'Sesi login tidak valid.');
      final refreshToken = session['refresh_token'] as String?;
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const ApiException('Server tidak mengirim sesi login.');
      }
      final authResponse = await _supabase.auth.setSession(refreshToken);
      return _signedInUser(authResponse.user, authResponse.session);
    } catch (error) {
      _apiError(error);
    }
  }

  static Map<String, dynamic> _signedInUser(User? user, Session? session) {
    if (user == null || session == null) {
      throw const ApiException('Akun atau password salah.');
    }
    return {
      'user': {'auth_id': user.id, 'email': user.email},
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
    };
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nama_lengkap_user': fullName,
          'username': username,
          'no_telephone': phone,
        },
      );
      final session = response.session;
      return {
        'user': response.user == null ? null : {'id': response.user!.id},
        'access_token': session?.accessToken,
        'refresh_token': session?.refreshToken,
        'email_confirmation_required': session == null,
      };
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> profile(String token) async {
    try {
      final row = await _supabase
          .from('users')
          .select(_profileColumns)
          .eq('auth_id', _supabase.auth.currentUser!.id)
          .single();
      return {'user': row};
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> summary(String token) async {
    try {
      final user = await profile(token);
      final userId = user['user']['id_user'] as int;
      final wishlist = await _supabase
          .from('wishlist')
          .select('id_wishlist')
          .eq('id_user', userId);
      final reviews = await _supabase
          .from('ulasan')
          .select('id_ulasan')
          .eq('id_user', userId);
      final tickets = await _supabase
          .from('e_tiket')
          .select('id_tiket, pemesanan!inner(id_user)')
          .eq('pemesanan.id_user', userId)
          .eq('status_tiket', 'aktif');
      return {
        'user': user['user'],
        'wishlist_count': (wishlist as List).length,
        'reviews_count': (reviews as List).length,
        'tickets_active': (tickets as List).length,
      };
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> values,
  ) async {
    try {
      final row = await _supabase
          .from('users')
          .update(values)
          .eq('auth_id', _supabase.auth.currentUser!.id)
          .select(_profileColumns)
          .single();
      return {'user': row};
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<void> logout(String token) async {
    try {
      await _supabase.auth.signOut();
      await SessionManager.logout();
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<List<Map<String, dynamic>>> orders(String token) async {
    try {
      final rows = await _supabase
          .from('pemesanan')
          .select(
            'id_pemesanan, kode_pesan, tgl_pesan, subtotal, diskon, biaya_layanan, total_bayar, status_pesan, pembayaran(status_bayar, metode_bayar, jumlah_bayar, waktu_bayar), kuota_harian(tanggal), e_tiket(kode_qr, status_tiket), detail_pemesanan(jumlah, harga_satuan, subtotal_harga_tiket, tipe_pengunjung, detail_paket(paket_wisata(nama_paket, wisata(id_wisata, nama_wisata, lokasi, foto_wisata(url_foto, urutan)))))',
          )
          .order('tgl_pesan', ascending: false)
          .limit(100);
      return _rows(rows, 'Data pesanan tidak valid.');
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<List<Map<String, dynamic>>> notifications(String token) async {
    try {
      final rows = await _supabase
          .from('notifikasi')
          .select('id_notifikasi, judul, isi, jenis, status_baca, tanggal')
          .order('tanggal', ascending: false)
          .limit(100);
      return _rows(rows, 'Data notifikasi tidak valid.');
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<void> markNotificationRead(String token, int id) async {
    try {
      await _supabase
          .from('notifikasi')
          .update({'status_baca': true})
          .eq('id_notifikasi', id);
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> points(String token) async {
    try {
      final profile = await _supabase
          .from('users')
          .select('id_user, total_poin')
          .eq('auth_id', _supabase.auth.currentUser!.id)
          .single();
      final rows = await _supabase
          .from('riwayat_poin')
          .select('id_riwayat, jenis, jumlah_poin, keterangan, tanggal')
          .eq('id_user', profile['id_user'])
          .order('tanggal', ascending: false)
          .limit(100);
      return {'saldo': profile['total_poin'], 'data': rows};
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<List<Map<String, dynamic>>> reviews(String token) async {
    try {
      final rows = await _supabase
          .from('ulasan')
          .select(
            'id_ulasan, id_wisata, id_pemesanan, rating, komentar, tanggal_ulasan, wisata(nama_wisata, lokasi, foto_wisata(url_foto, urutan))',
          )
          .order('tanggal_ulasan', ascending: false)
          .limit(100);
      return _rows(rows, 'Data ulasan tidak valid.');
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> createReview({
    required String token,
    required int orderId,
    required int wisataId,
    required int rating,
    String? comment,
  }) async {
    try {
      final user = await _supabase
          .from('users')
          .select('id_user')
          .eq('auth_id', _supabase.auth.currentUser!.id)
          .single();
      final row = await _supabase
          .from('ulasan')
          .insert({
            'id_user': user['id_user'],
            'id_pemesanan': orderId,
            'id_wisata': wisataId,
            'rating': rating,
            'komentar': comment,
          })
          .select(
            'id_ulasan, id_wisata, id_pemesanan, rating, komentar, tanggal_ulasan',
          )
          .single();
      return {'data': row};
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<List<Map<String, dynamic>>> catalog() async {
    try {
      final rows = await _supabase
          .from('wisata')
          .select(
            'id_wisata, nama_wisata, lokasi, kota, deskripsi, jenis, subkategori, rata_rating, jml_ulasan, id_kategori, kategori(nama_kategori), paket_wisata!inner(id_paket, nama_paket, tipe_paket, status_aktif, detail_paket(id_detail_paket, harga, tipe_pengunjung)), foto_wisata(url_foto, urutan)',
          )
          .eq('status_approve', 'Y')
          .eq('paket_wisata.status_aktif', true)
          .order('id_wisata');
      return _rows(rows, 'Data wisata tidak valid.');
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<List<Map<String, dynamic>>> wishlist(String token) async {
    try {
      final rows = await _supabase
          .from('wishlist')
          .select(
            'id_wishlist, id_wisata, wisata(id_wisata, nama_wisata, lokasi, kota, rata_rating, jml_ulasan, kategori(nama_kategori), paket_wisata(id_paket, nama_paket, tipe_paket, detail_paket(harga, tipe_pengunjung)), foto_wisata(url_foto, urutan))',
          )
          .order('id_wishlist', ascending: false);
      return _rows(rows, 'Data wishlist tidak valid.');
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<void> addWishlist(String token, int wisataId) async {
    try {
      await _supabase
          .from('wishlist')
          .upsert(
            {'id_user': await _currentUserId(), 'id_wisata': wisataId},
            onConflict: 'id_user,id_wisata',
            ignoreDuplicates: true,
          );
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<void> removeWishlist(String token, int wisataId) async {
    try {
      await _supabase
          .from('wishlist')
          .delete()
          .eq('id_user', await _currentUserId())
          .eq('id_wisata', wisataId);
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<int> _currentUserId() async {
    final row = await _supabase
        .from('users')
        .select('id_user')
        .eq('auth_id', _supabase.auth.currentUser!.id)
        .single();
    return row['id_user'] as int;
  }
}

class MitraApi {
  static const _profileColumns =
      'id_mitra, id_admin, username, nama_lengkap_admin, email, no_telephone';

  static Future<String> _sessionToken() async {
    final token = await SessionManager.currentMitraToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Sesi mitra tidak tersedia. Silakan login kembali.',
      );
    }
    return token;
  }

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'smart-endpoint',
        body: {
          'action': 'mitra_login',
          'identifier': identifier.trim(),
          'password': password,
        },
      );
      final payload = _map(response.data, 'Respons login mitra tidak valid.');
      final token = payload['mitra_session'] as String?;
      final mitra = _map(payload['mitra'], 'Profil mitra tidak valid.');
      if (token == null || token.isEmpty) {
        throw const ApiException('Sesi login mitra tidak valid.');
      }
      return {
        'mitra': mitra,
        'access_token': token,
        'refresh_token': null,
      };
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<bool> validateSession(String token) async {
    try {
      await _supabase.functions.invoke(
        'smart-endpoint',
        body: {'action': 'mitra_session_check', 'mitra_session': token},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _sessionToken();
      await _supabase.functions.invoke(
        'smart-endpoint',
        body: {
          'action': 'mitra_change_password',
          'mitra_session': token,
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<void> changeEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    try {
      final token = await _sessionToken();
      final response = await _supabase.functions.invoke(
        'smart-endpoint',
        body: {
          'action': 'mitra_change_email',
          'mitra_session': token,
          'current_password': currentPassword,
          'new_email': newEmail.trim().toLowerCase(),
        },
      );
      final payload = _map(
        response.data,
        'Respons perubahan email tidak valid.',
      );
      final newToken = payload['mitra_session'] as String?;
      if (newToken != null) {
        await SessionManager.setMitraDatabaseSession(token: newToken);
      }
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> profile(String token) async {
    try {
      final row = await _supabase
          .from('admin_wisata')
          .select(_profileColumns)
          .limit(1)
          .single();
      return {'mitra': row};
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> values,
  ) async {
    try {
      final row = await _supabase
          .from('admin_wisata')
          .update(values)
          .eq('id_mitra', await _currentMitraId())
          .select(_profileColumns)
          .single();
      return {'mitra': row};
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> ringkasan(String token) async {
    try {
      final mitraId = await _currentMitraId();
      final wisataRows = await _supabase
          .from('wisata')
          .select('id_wisata, status_approve')
          .eq('id_mitra', mitraId);
      final dokumenRows = await _supabase
          .from('dokumen')
          .select('id_dokumen, status_approve')
          .eq('id_mitra', mitraId);
      final status = await _supabase
          .from('status_mitra_admin')
          .select('status_mitra, ditampilkan_di_beranda')
          .eq('id_mitra', mitraId)
          .maybeSingle();
      final wisata = _rows(wisataRows, 'Data wisata mitra tidak valid.');
      final dokumen = _rows(dokumenRows, 'Data dokumen mitra tidak valid.');
      final paymentSummary = _map(
        await _supabase.rpc('mitra_ringkasan_pembayaran'),
        'Ringkasan pembayaran mitra tidak valid.',
      );
      return {
        'ringkasan': {
          'total_destinasi': wisata.length,
          'destinasi_disetujui': wisata
              .where((row) => row['status_approve'] == 'Y')
              .length,
          'total_dokumen': dokumen.length,
          'dokumen_disetujui': dokumen
              .where((row) => row['status_approve'] == 'Y')
              .length,
          'pesanan_terbayar': paymentSummary['pesanan_terbayar'] ?? 0,
          'nilai_pembayaran_berhasil':
              paymentSummary['nilai_pembayaran_berhasil'] ?? 0,
          'status_mitra': status?['status_mitra'],
          'ditampilkan_di_beranda': status?['ditampilkan_di_beranda'] ?? false,
        },
      };
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<List<Map<String, dynamic>>> wisata(String token) async {
    try {
      final rows = await _supabase
          .from('wisata')
          .select(
            'id_wisata, id_mitra, id_kategori, nama_wisata, lokasi, kota, jam_buka, jam_tutup, deskripsi, jenis, subkategori, rata_rating, jml_ulasan, status_approve, kategori(nama_kategori), foto_wisata(id_foto, url_foto, urutan), paket_wisata(id_paket, nama_paket, tipe_paket, status_aktif, detail_paket(id_detail_paket, tipe_pengunjung, harga))',
          )
          .eq('id_mitra', await _currentMitraId())
          .order('id_wisata', ascending: false);
      return _rows(rows, 'Data wisata mitra tidak valid.');
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<void> updateWisata({
    required String token,
    required int idWisata,
    required Map<String, dynamic> values,
  }) async {
    try {
      await _supabase
          .from('wisata')
          .update(values)
          .eq('id_wisata', idWisata)
          .eq('id_mitra', await _currentMitraId());
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<void> updatePaket({
    required String token,
    required int idPaket,
    required Map<String, dynamic> values,
  }) async {
    try {
      await _supabase
          .from('paket_wisata')
          .update(values)
          .eq('id_paket', idPaket);
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<void> updateHargaPaket({
    required String token,
    required int idDetailPaket,
    required int harga,
  }) async {
    try {
      await _supabase
          .from('detail_paket')
          .update({'harga': harga})
          .eq('id_detail_paket', idDetailPaket);
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<List<Map<String, dynamic>>> dokumen(String token) async {
    try {
      final rows = await _supabase
          .from('dokumen')
          .select(
            'id_dokumen, id_mitra, jenis_dokumen, nomor_dokumen, file_dokumen, status_approve, masa_berlaku_sampai, catatan_admin, diperiksa_pada',
          )
          .eq('id_mitra', await _currentMitraId())
          .order('id_dokumen', ascending: false);
      return await Future.wait(
        _rows(rows, 'Data dokumen mitra tidak valid.').map((row) async {
          final storedFile = row['file_dokumen']?.toString() ?? '';
          final parts = storedFile.split('/');
          if (parts.length < 2 || parts.first != 'lokatrip-legalitas') {
            return row;
          }
          try {
            final signed = await _supabase.storage
                .from(parts.first)
                .createSignedUrl(parts.skip(1).join('/'), 60 * 30);
            return {...row, 'nama_berkas': parts.last, 'url_berkas': signed};
          } catch (_) {
            return {...row, 'nama_berkas': parts.last};
          }
        }),
      );
    } catch (error) {
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> uploadDokumen({
    required String token,
    required String jenisDokumen,
    required String nomorDokumen,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    String? path;
    try {
      final mitraId = await _currentMitraId();
      path = await _uploadFile(
        bucket: 'lokatrip-legalitas',
        mitraId: mitraId,
        name: fileName,
        mimeType: mimeType,
        bytes: bytes,
      );
      final row = await _supabase
          .from('dokumen')
          .insert({
            'id_mitra': mitraId,
            'jenis_dokumen': jenisDokumen,
            'nomor_dokumen': nomorDokumen.trim().isEmpty
                ? null
                : nomorDokumen.trim(),
            'file_dokumen': 'lokatrip-legalitas/$path',
          })
          .select(
            'id_dokumen, id_mitra, jenis_dokumen, nomor_dokumen, file_dokumen, status_approve, masa_berlaku_sampai, catatan_admin, diperiksa_pada',
          )
          .single();
      final signed = await _supabase.storage
          .from('lokatrip-legalitas')
          .createSignedUrl(path, 60 * 30);
      return {
        'document': {...row, 'nama_berkas': fileName, 'url_berkas': signed},
      };
    } catch (error) {
      if (path != null) {
        try {
          await _supabase.storage.from('lokatrip-legalitas').remove([path]);
        } catch (_) {}
      }
      _apiError(error);
    }
  }

  static Future<Map<String, dynamic>> submitPengajuan({
    required String token,
    required Map<String, dynamic> values,
    String? fotoName,
    String? fotoMimeType,
    Uint8List? fotoBytes,
    List<Map<String, dynamic>> dokumen = const [],
  }) async {
    final uploadedFiles = <(String, String)>[];
    final documentIds = <int>[];
    int? wisataId;
    int? packageId;
    int? detailId;
    int? photoId;

    Future<void> rollback() async {
      try {
        if (documentIds.isNotEmpty) {
          await _supabase
              .from('dokumen')
              .delete()
              .inFilter('id_dokumen', documentIds);
        }
        if (photoId != null) {
          await _supabase.from('foto_wisata').delete().eq('id_foto', photoId);
        }
        if (packageId != null) {
          await _supabase
              .from('kuota_harian')
              .delete()
              .eq('id_paket', packageId);
          if (detailId != null) {
            await _supabase
                .from('detail_paket')
                .delete()
                .eq('id_detail_paket', detailId);
          }
          await _supabase
              .from('paket_wisata')
              .delete()
              .eq('id_paket', packageId!);
        }
        if (wisataId != null) {
          await _supabase.from('wisata').delete().eq('id_wisata', wisataId);
        }
        for (final file in uploadedFiles) {
          await _supabase.storage.from(file.$1).remove([file.$2]);
        }
      } catch (_) {}
    }

    try {
      final mitraId = await _currentMitraId();
      final categories = _rows(
        await _supabase.from('kategori').select('id_kategori, nama_kategori'),
        'Daftar kategori wisata tidak valid.',
      );
      const categoryAliases = {
        'wisata alam': 'alam & outbound',
        'wisata budaya': 'candi & budaya',
        'wisata bahari': 'tur & open trip',
        'taman rekreasi': 'atraksi & rekreasi',
        'petualangan': 'alam & outbound',
      };
      final requestedCategory = (values['kategori'] as String? ?? '')
          .trim()
          .toLowerCase();
      final categoryName =
          categoryAliases[requestedCategory] ?? requestedCategory;
      final category = categories.cast<Map<String, dynamic>?>().firstWhere(
        (row) =>
            row?['nama_kategori']?.toString().toLowerCase() == categoryName,
        orElse: () => null,
      );
      if (category == null) {
        throw const ApiException('Kategori wisata tidak tersedia.');
      }

      final hours = (values['jam_operasional'] as String? ?? '');
      final hourMatches = RegExp(
        r'(\d{1,2})[:.](\d{2})',
      ).allMatches(hours).toList();
      if (hourMatches.length < 2) {
        throw const ApiException(
          'Jam operasional harus memuat jam buka dan tutup, contoh 08.00-17.00.',
        );
      }
      String pgTime(Match match) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        if (hour > 23 || minute > 59) {
          throw const ApiException('Jam operasional tidak valid.');
        }
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
      }

      final price = int.tryParse(values['harga'].toString());
      final quota = int.tryParse(values['kuota'].toString());
      if (price == null || price < 0 || quota == null || quota < 1) {
        throw const ApiException('Harga tiket atau kuota harian tidak valid.');
      }

      String? photoPath;
      if (fotoBytes != null && fotoName != null && fotoMimeType != null) {
        photoPath = await _uploadFile(
          bucket: 'lokatrip-wisata',
          mitraId: mitraId,
          name: fotoName,
          mimeType: fotoMimeType,
          bytes: fotoBytes,
        );
        uploadedFiles.add(('lokatrip-wisata', photoPath));
      }
      final uploadedDocuments = <Map<String, dynamic>>[];
      for (final item in dokumen) {
        final path = await _uploadFile(
          bucket: 'lokatrip-legalitas',
          mitraId: mitraId,
          name: item['name'] as String,
          mimeType: item['mime_type'] as String,
          bytes: item['bytes'] as Uint8List,
        );
        uploadedFiles.add(('lokatrip-legalitas', path));
        uploadedDocuments.add({...item, 'path': path});
      }

      final location = (values['lokasi'] as String? ?? '').trim();
      final locationParts = location
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      final wisata = await _supabase
          .from('wisata')
          .insert({
            'id_mitra': mitraId,
            'id_kategori': category['id_kategori'],
            'nama_wisata': values['nama_wisata'],
            'lokasi': location,
            'kota': locationParts.length > 1 ? locationParts.last : null,
            'jam_buka': pgTime(hourMatches.first),
            'jam_tutup': pgTime(hourMatches[1]),
            'deskripsi': values['deskripsi'],
            'jenis': category['nama_kategori'],
            'subkategori': values['kategori'],
            'status_approve': 'N',
          })
          .select('id_wisata')
          .single();
      wisataId = (wisata['id_wisata'] as num).toInt();

      final paket = await _supabase
          .from('paket_wisata')
          .insert({
            'id_wisata': wisataId,
            'nama_paket': values['nama_paket'],
            'tipe_paket': 'reguler',
            'deskripsi': values['deskripsi'],
            'status_aktif': true,
          })
          .select('id_paket')
          .single();
      packageId = (paket['id_paket'] as num).toInt();

      final detail = await _supabase
          .from('detail_paket')
          .insert({
            'id_paket': packageId,
            'tipe_pengunjung': 'dewasa',
            'harga': price,
          })
          .select('id_detail_paket')
          .single();
      detailId = (detail['id_detail_paket'] as num).toInt();

      final today = DateTime.now();
      final quotas = List.generate(60, (index) {
        final date = today.add(Duration(days: index));
        final dateString =
            '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        return {
          'id_paket': packageId,
          'tanggal': dateString,
          'kuota_total': quota,
          'kuota_terpakai': 0,
        };
      });
      await _supabase.from('kuota_harian').insert(quotas);

      if (photoPath != null) {
        final publicUrl = _supabase.storage
            .from('lokatrip-wisata')
            .getPublicUrl(photoPath);
        final photo = await _supabase
            .from('foto_wisata')
            .insert({'id_wisata': wisataId, 'url_foto': publicUrl, 'urutan': 1})
            .select('id_foto')
            .single();
        photoId = (photo['id_foto'] as num).toInt();
      }

      if (uploadedDocuments.isNotEmpty) {
        final inserted = await _supabase
            .from('dokumen')
            .insert(
              uploadedDocuments
                  .map(
                    (item) => {
                      'id_mitra': mitraId,
                      'jenis_dokumen': item['jenis_dokumen'],
                      'nomor_dokumen':
                          (item['nomor_dokumen'] as String?)?.trim().isEmpty ==
                              true
                          ? null
                          : item['nomor_dokumen'],
                      'file_dokumen': 'lokatrip-legalitas/${item['path']}',
                    },
                  )
                  .toList(),
            )
            .select('id_dokumen');
        documentIds.addAll(
          _rows(
            inserted,
            'Dokumen pengajuan tidak valid.',
          ).map((row) => (row['id_dokumen'] as num).toInt()),
        );
      }
      return {
        'success': true,
        'application': {
          'id_wisata': wisataId,
          'id_paket': packageId,
          'status_approve': 'N',
        },
      };
    } catch (error) {
      await rollback();
      _apiError(error);
    }
  }

  static Future<String> _uploadFile({
    required String bucket,
    required int mitraId,
    required String name,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty || bytes.length > 8 * 1024 * 1024) {
      throw const ApiException('Ukuran setiap berkas maksimal 8 MB.');
    }
    final safeName = name.replaceAll(RegExp(r'[^\w.-]'), '_');
    final path = '$mitraId/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    await _supabase.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );
    return path;
  }

  static Future<void> logout(String token) async {
    try {
      await _supabase.functions.invoke(
        'smart-endpoint',
        body: {'action': 'mitra_logout', 'mitra_session': token},
      );
    } catch (_) {
      // Keep logout available even when the network is offline; the server-side
      // session expires automatically.
    } finally {
      await SessionManager.logout();
    }
  }

  static Future<int> _currentMitraId() async {
    final row = await _supabase
        .from('admin_wisata')
        .select('id_mitra')
        .limit(1)
        .single();
    return row['id_mitra'] as int;
  }
}
