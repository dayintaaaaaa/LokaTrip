import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyLogin = 'is_logged_in';

  // cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogin) ?? false;
  }

  // dipanggil setelah login/daftar berhasil
  static Future<void> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
  }

  // dipanggil saat logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, false);
  }
}