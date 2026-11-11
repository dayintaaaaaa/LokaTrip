import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyLogin = 'is_logged_in';
  static const _keyRole = 'account_role';

  // cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogin) ?? false;
  }

  static Future<String> accountRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole) ?? 'wisatawan';
  }

  // dipanggil setelah login/daftar berhasil
  static Future<void> setLoggedIn({String role = 'wisatawan'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
    await prefs.setString(_keyRole, role);
  }

  // dipanggil saat logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, false);
    await prefs.remove(_keyRole);
  }
}
