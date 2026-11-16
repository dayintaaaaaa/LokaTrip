import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Ambil & ubah data profil user yang sedang login (tabel public.users).
class ProfileService {
  final SupabaseClient _db = Supabase.instance.client;

  /// Kolom penghubung ke akun login (auth.users.id).
  static const _kolomKunci = 'auth_id';

  String get _uid {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw AuthFailure('Sesi habis, silakan login lagi');
    return id;
  }

  /// +62812... -> 0812... (hanya untuk tampilan di form)
  static String keFormatLokal(String phone) =>
      phone.startsWith('+62') ? '0${phone.substring(3)}' : phone;

  // Label di UI  ->  nilai enum jenis_kelamin_enum di database
  static const _genderKeDb = {
    'Laki-laki': 'L',
    'Perempuan': 'P',
  };

  static String? genderKeDb(String? label) =>
      label == null ? null : _genderKeDb[label];

  static String? genderKeLabel(String? nilaiDb) {
    for (final e in _genderKeDb.entries) {
      if (e.value == nilaiDb) return e.key;
    }
    return null;
  }

  /// Ambil profil user yang sedang login.
  /// pin_transaksi sengaja tidak ikut diambil.
  Future<Map<String, dynamic>> getProfile() async {
    try {
      return await _db
          .from('users')
          .select(
            'nama_lengkap_user, username, no_telephone, tgl_lahir, '
            'jenis_kelamin, foto_profil, total_poin, status_verif',
          )
          .eq(_kolomKunci, _uid)
          .single();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('Muat profil gagal: $e');
      throw AuthFailure('Gagal memuat profil: $e');
    }
  }

  /// Simpan perubahan profil.
  /// Hanya kolom yang di-grant update yang boleh diubah dari aplikasi.
  Future<void> updateProfile({
    required String namaLengkap,
    required String noTelepon,
    DateTime? tanggalLahir,
    String? jenisKelamin, // label UI: 'Laki-laki' / 'Perempuan'
  }) async {
    try {
      final hasil = await _db
          .from('users')
          .update({
            'nama_lengkap_user': namaLengkap.trim(),
            // simpan format +62 supaya login pakai nomor tetap cocok
            'no_telephone': AuthService.normalizePhone(noTelepon),
            'tgl_lahir': tanggalLahir?.toIso8601String().substring(0, 10),
            'jenis_kelamin': genderKeDb(jenisKelamin),
          })
          .eq(_kolomKunci, _uid)
          .select('auth_id');

      // RLS yang memblokir update tidak memunculkan error, hanya 0 baris
      if (hasil.isEmpty) {
        debugPrint('Update 0 baris: cek policy RLS dan isi kolom auth_id');
        throw AuthFailure(
          'Tidak ada data yang berubah. Cek policy RLS / kolom auth_id.',
        );
      }
    } on AuthFailure {
      rethrow;
    } on PostgrestException catch (e) {
      debugPrint(
        'Update gagal: code=${e.code} msg=${e.message} details=${e.details}',
      );
      // 23505 = unique violation (nomor telepon sudah dipakai akun lain)
      if (e.code == '23505') {
        throw AuthFailure('Nomor telepon sudah dipakai akun lain');
      }
      throw AuthFailure('Gagal menyimpan: ${e.message}');
    } catch (e) {
      debugPrint('Update error: $e');
      throw AuthFailure('Gagal menyimpan: $e');
    }
  }

  /// Upload foto, simpan URL ke kolom foto_profil, return URL-nya.
  Future<String> uploadFoto(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw AuthFailure('Ukuran foto maksimal 5MB');
      }

      final path = '$_uid/avatar';
      await _db.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: file.mimeType ?? 'image/jpeg',
            ),
          );

      // tambah ?t= supaya gambar baru tidak tertahan cache
      final url =
          '${_db.storage.from('avatars').getPublicUrl(path)}?t=${DateTime.now().millisecondsSinceEpoch}';

      await _db
          .from('users')
          .update({'foto_profil': url}).eq(_kolomKunci, _uid);
      return url;
    } on AuthFailure {
      rethrow;
    } catch (e) {
      debugPrint('Upload foto gagal: $e');
      throw AuthFailure('Gagal mengunggah foto: $e');
    }
  }

  /// Hapus foto di Storage dan kosongkan kolom foto_profil.
  Future<void> hapusFoto() async {
    try {
      await _db.storage.from('avatars').remove(['$_uid/avatar']);
      await _db
          .from('users')
          .update({'foto_profil': null}).eq(_kolomKunci, _uid);
    } catch (e) {
      debugPrint('Hapus foto gagal: $e');
      throw AuthFailure('Gagal menghapus foto: $e');
    }
  }
}