import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager {
  static const _keyLogin = 'is_logged_in';
  static const _keyRole = 'account_role';
  static const _keyUserToken = 'user_access_token';
  static const _keyUserRefreshToken = 'user_refresh_token';
  static const _keyAdminToken = 'admin_access_token';
  static const _keyAdminRefreshToken = 'admin_refresh_token';
  static const _keyMitraToken = 'mitra_access_token';
  static const _keyMitraRefreshToken = 'mitra_refresh_token';
  static String? _adminAccessToken;
  static String? _adminRefreshToken;
  static String? _userAccessToken;
  static String? _userRefreshToken;
  static String? _mitraAccessToken;
  static String? _mitraRefreshToken;

  static String? get adminAccessToken => _adminAccessToken;
  static String? get userAccessToken => _userAccessToken;
  static String? get mitraAccessToken => _mitraAccessToken;

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
    if (role != 'admin') _adminAccessToken = null;
    if (role != 'admin') _adminRefreshToken = null;
    if (role != 'wisatawan') _userAccessToken = null;
    if (role != 'mitra') {
      _mitraAccessToken = null;
      _mitraRefreshToken = null;
      _setMitraHeader(null);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
    await prefs.setString(_keyRole, role);
    if (role != 'wisatawan') {
      await prefs.remove(_keyUserToken);
      await prefs.remove(_keyUserRefreshToken);
    }
    if (role != 'mitra') {
      await prefs.remove(_keyMitraToken);
      await prefs.remove(_keyMitraRefreshToken);
    }
    if (role != 'admin') {
      await prefs.remove(_keyAdminToken);
      await prefs.remove(_keyAdminRefreshToken);
    }
  }

  static Future<void> setUserSession({
    required String accessToken,
    String? refreshToken,
  }) async {
    await setLoggedIn(role: 'wisatawan');
    _userAccessToken = accessToken;
    _userRefreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
    await prefs.setString(_keyRole, 'wisatawan');
    await prefs.setString(_keyUserToken, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_keyUserRefreshToken, refreshToken);
    }
  }

  static Future<String?> currentUserToken() async {
    if (_userAccessToken != null) return _userAccessToken;
    final prefs = await SharedPreferences.getInstance();
    _userAccessToken = prefs.getString(_keyUserToken);
    return _userAccessToken;
  }

  static Future<String?> currentUserRefreshToken() async {
    if (_userRefreshToken != null) return _userRefreshToken;
    final prefs = await SharedPreferences.getInstance();
    _userRefreshToken = prefs.getString(_keyUserRefreshToken);
    return _userRefreshToken;
  }

  static Future<void> setMitraDatabaseSession({required String token}) async {
    await setLoggedIn(role: 'mitra');
    _mitraAccessToken = token;
    _mitraRefreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
    await prefs.setString(_keyRole, 'mitra');
    await prefs.setString(_keyMitraToken, token);
    await prefs.remove(_keyMitraRefreshToken);
    _setMitraHeader(token);
  }

  static void _setMitraHeader(String? token) {
    final client = Supabase.instance.client;
    final headers = Map<String, String>.from(client.headers)
      ..remove('x-mitra-session');
    if (token != null && token.isNotEmpty) {
      headers['X-Client-Info'] = 'lokatrip-mitra-session/$token';
    } else {
      headers.remove('X-Client-Info');
    }
    client.headers = headers;
  }

  static Future<String?> currentMitraToken() async {
    if (_mitraAccessToken != null) {
      _setMitraHeader(_mitraAccessToken);
      return _mitraAccessToken;
    }
    final prefs = await SharedPreferences.getInstance();
    _mitraAccessToken = prefs.getString(_keyMitraToken);
    if (_mitraAccessToken != null) _setMitraHeader(_mitraAccessToken);
    return _mitraAccessToken;
  }

  static Future<String?> currentMitraRefreshToken() async {
    if (_mitraRefreshToken != null) return _mitraRefreshToken;
    final prefs = await SharedPreferences.getInstance();
    _mitraRefreshToken = prefs.getString(_keyMitraRefreshToken);
    return _mitraRefreshToken;
  }

  static Future<void> setAdminSession({
    required String accessToken,
    String? refreshToken,
  }) async {
    _adminAccessToken = accessToken;
    _adminRefreshToken = refreshToken;
    await setLoggedIn(role: 'admin');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAdminToken, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_keyAdminRefreshToken, refreshToken);
    }
  }

  static Future<String?> currentAdminToken() async {
    if (_adminAccessToken != null) return _adminAccessToken;
    final prefs = await SharedPreferences.getInstance();
    _adminAccessToken = prefs.getString(_keyAdminToken);
    return _adminAccessToken;
  }

  static Future<String?> currentAdminRefreshToken() async {
    if (_adminRefreshToken != null) return _adminRefreshToken;
    final prefs = await SharedPreferences.getInstance();
    _adminRefreshToken = prefs.getString(_keyAdminRefreshToken);
    return _adminRefreshToken;
  }

  // dipanggil saat logout
  static Future<void> logout() async {
    _adminAccessToken = null;
    _adminRefreshToken = null;
    _userAccessToken = null;
    _userRefreshToken = null;
    _mitraAccessToken = null;
    _mitraRefreshToken = null;
    _setMitraHeader(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, false);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyAdminToken);
    await prefs.remove(_keyAdminRefreshToken);
    await prefs.remove(_keyUserToken);
    await prefs.remove(_keyUserRefreshToken);
    await prefs.remove(_keyMitraToken);
    await prefs.remove(_keyMitraRefreshToken);
  }
}
