import 'package:supabase_flutter/supabase_flutter.dart';

/// Error yang pesannya aman ditampilkan langsung ke user.
class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final SupabaseClient _db = Supabase.instance.client;

  /// Samakan format nomor telepon: 0812... / 62812... / +62812... -> +62812...
  /// Aturannya harus sama persis dengan di Edge Function (smart-endpoint).
  static String normalizePhone(String input) {
    final p = input.replaceAll(RegExp(r'[\s\-()]'), '');
    if (p.startsWith('+62')) return p;
    if (p.startsWith('62')) return '+$p';
    if (p.startsWith('0')) return '+62${p.substring(1)}';
    return p;
  }

  /// Daftar akun baru.
  /// Return true  -> user langsung login (Confirm email dimatikan).
  /// Return false -> user harus konfirmasi lewat email dulu.
  Future<bool> register({
    required String namaLengkap,
    required String username,
    required String email,
    required String password,
    required String noTelepon,
  }) async {
    final phone = normalizePhone(noTelepon);
    try {
      // Cek username dan nomor telepon belum dipakai
      final cek = await _db.rpc('cek_ketersediaan', params: {
        'p_username': username.trim(),
        'p_no_telephone': phone,
      });
      final row = (cek as List).first as Map<String, dynamic>;
      if (row['username_tersedia'] != true) {
        throw AuthFailure('Username sudah dipakai');
      }
      if (row['telepon_tersedia'] != true) {
        throw AuthFailure('Nomor telepon sudah terdaftar');
      }

      // Buat akun. Data profil dikirim sebagai metadata, lalu trigger di
      // database otomatis membuat baris di tabel users.
      final res = await _db.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nama_lengkap_user': namaLengkap.trim(),
          'username': username.trim(),
          'no_telephone': phone,
        },
      );
      return res.session != null;
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Pendaftaran gagal, coba lagi');
    }
  }

  /// Login pakai email atau nomor telepon.
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim();
    try {
      if (id.contains('@')) {
        // Login pakai email
        await _db.auth.signInWithPassword(email: id, password: password);
      } else {
        // Login pakai nomor telepon lewat Edge Function
        final res = await _db.functions.invoke('smart-endpoint', body: {
          'phone': normalizePhone(id),
          'password': password,
        });
        final refresh = res.data['session']['refresh_token'] as String;
        await _db.auth.setSession(refresh);
      }
    } on AuthException {
      throw AuthFailure('Nomor/email atau password salah');
    } on FunctionException {
      throw AuthFailure('Nomor/email atau password salah');
    } catch (_) {
      throw AuthFailure('Login gagal, periksa koneksi internetmu');
    }
  }

  /// Kirim link reset password ke email.
  Future<void> forgotPassword(String email) async {
    try {
      await _db.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Gagal mengirim email, coba lagi');
    }
  }

  Future<void> logout() => _db.auth.signOut();

  /// True kalau masih ada sesi login (dipakai di splash screen).
  bool get isLoggedIn => _db.auth.currentSession != null;
}