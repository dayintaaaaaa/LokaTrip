import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokatrip/services/auth_service.dart';
import '../core/api_client.dart';
import '../core/app_color.dart';
import '../core/session_manager.dart';
import '../features/register_screens.dart';
import '../features/user/home_screens.dart';
import 'admin/dashboard_admin_screens.dart';
import 'admin_mitra/wisata_saya_mitra_screen.dart';

class LoginScreens extends StatefulWidget {
  const LoginScreens({super.key});

  @override
  State<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hiddenPass = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _pesan(String teks) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _login() async {
    if (_loading) return;

    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      _pesan('Email/username/nomor telepon dan password wajib diisi.');
      return;
    }

    setState(() => _loading = true);

    try {
      final client = Supabase.instance.client;

      if (!identifier.contains('@')) {
        // Username atau nomor telepon diproses melalui Edge Function.
        final response = await client.functions.invoke(
          'smart-endpoint',
          body: {
            'identifier': identifier,
            'phone': identifier,
            'password': password,
          },
        );

        final payload = response.data;
        if (payload is! Map) {
          throw const ApiException('Respons login tidak valid.');
        }

        final loginSession = payload['session'];
        if (loginSession is! Map) {
          throw ApiException(payload['error'] as String? ?? 'Login gagal.');
        }

        final accessToken = loginSession['access_token'] as String?;
        final refreshToken = loginSession['refresh_token'] as String?;
        var resolvedRole = payload['role'] as String?;

        if (accessToken == null || refreshToken == null) {
          throw const ApiException('Sesi login tidak valid.');
        }

        final restored = await client.auth.setSession(refreshToken);
        final activeSession = restored.session;

        if (activeSession == null) {
          throw const ApiException('Sesi login tidak dapat diaktifkan.');
        }

        // Deteksi role dari profil jika Edge Function belum mengembalikannya.
        if (resolvedRole == null) {
          final authUser = restored.user;

          if (authUser == null) {
            throw const ApiException('Profil login tidak dapat dibaca.');
          }

          final admin = await client
              .from('admin_lokatrip')
              .select('id_admin')
              .eq('auth_id', authUser.id)
              .maybeSingle();

          if (admin != null) {
            resolvedRole = 'admin';
          } else {
            final email = authUser.email;
            if (email != null) {
              final mitra = await client
                  .from('admin_wisata')
                  .select('id_mitra')
                  .eq('email', email)
                  .maybeSingle();

              if (mitra != null) {
                resolvedRole = 'mitra';
              }
            }

            if (resolvedRole == null) {
              final profile = await client
                  .from('users')
                  .select('id_user')
                  .eq('auth_id', authUser.id)
                  .maybeSingle();

              if (profile != null) resolvedRole = 'wisatawan';
            }
          }
        }

        final destination = switch (resolvedRole) {
          'admin' => const DashboardAdminScreens(),
          'mitra' => const WisataSayaMitraScreen(),
          'wisatawan' => const HomeScreens(),
          _ => throw const ApiException('Jenis akun belum terdaftar.'),
        };

        if (resolvedRole == 'admin') {
          await SessionManager.setAdminSession(
            accessToken: activeSession.accessToken,
            refreshToken: activeSession.refreshToken,
          );
        } else if (resolvedRole == 'mitra') {
          await SessionManager.setMitraSession(
            accessToken: activeSession.accessToken,
            refreshToken: activeSession.refreshToken,
          );
        } else {
          await SessionManager.setUserSession(
            accessToken: activeSession.accessToken,
            refreshToken: activeSession.refreshToken,
          );
        }

        if (mounted) _openHome(destination);
        return;
      }

      // Login menggunakan email.
      final response = await client.auth.signInWithPassword(
        email: identifier,
        password: password,
      );

      final user = response.user;
      final session = response.session;

      if (user == null || session == null) {
        throw const ApiException('Email atau password salah.');
      }

      final admin = await client
          .from('admin_lokatrip')
          .select('id_admin')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (admin != null) {
        await SessionManager.setAdminSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
        if (mounted) _openHome(const DashboardAdminScreens());
        return;
      }

      final email = user.email;
      if (email != null) {
        final mitra = await client
            .from('admin_wisata')
            .select('id_mitra')
            .eq('email', email)
            .maybeSingle();

        if (mitra != null) {
          await SessionManager.setMitraSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
          );
          if (mounted) _openHome(const WisataSayaMitraScreen());
          return;
        }
      }

      final profile = await client
          .from('users')
          .select('id_user')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (profile != null) {
        await SessionManager.setUserSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
        if (mounted) _openHome(const HomeScreens());
        return;
      }

      await client.auth.signOut();
      throw const ApiException('Akun belum terhubung ke profil LokaTrip.');
    } on ApiException catch (error) {
      _pesan(error.message);
    } on AuthException catch (error) {
      _pesan(error.message);
    } on PostgrestException catch (error) {
      await Supabase.instance.client.auth.signOut();
      _pesan(error.message);
    } catch (error) {
      _pesan('Login gagal: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openHome(Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
      (_) => false,
    );
  }

  Future<void> _lupaPassword() async {
    final emailController = TextEditingController(
      text: _emailController.text.contains('@')
          ? _emailController.text.trim()
          : '',
    );

    try {
      final kirim = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: 420,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            decoration: BoxDecoration(
              color: AppColor.putih,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColor.hitam.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lupa Password?',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Masukkan email akunmu. Kami akan mengirim link untuk mengatur ulang password.',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColor.abu,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Email',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  style: GoogleFonts.manrope(fontSize: 12),
                  decoration: _inputDecoration('email@contoh.com'),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.ungu,
                          side: BorderSide(
                            color: AppColor.ungu.withValues(alpha: 0.35),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.kuning,
                          foregroundColor: AppColor.putih,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Kirim Link',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (kirim != true) return;

      final email = emailController.text.trim();
      if (!email.contains('@')) {
        _pesan('Email tidak valid.');
        return;
      }

      await AuthService().forgotPassword(email);
      _pesan('Jika email terdaftar, link reset password sudah dikirim.');
    } on AuthFailure catch (error) {
      _pesan(error.message);
    } finally {
      emailController.dispose();
    }
  }

  void _signIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreens()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.ungu, AppColor.biru, AppColor.putih],
            stops: [0.0, 0.45, 0.8],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  'Login',
                  style: GoogleFonts.outfit(
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                    color: AppColor.putih,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Jelajahi destinasi impianmu dengan kami.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: AppColor.putih,
                  ),
                ),
                const SizedBox(height: 100),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 24, 28),
                  decoration: BoxDecoration(
                    color: AppColor.putih,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.hitam.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Email, username, atau nomor telepon',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.hitam,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.manrope(fontSize: 12),
                        decoration: _inputDecoration(
                          'email@contoh.com atau nama pengguna',
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Password',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.hitam,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _hiddenPass,
                        style: GoogleFonts.manrope(fontSize: 12),
                        decoration: _inputDecoration('masukkan password')
                            .copyWith(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _hiddenPass = !_hiddenPass);
                                },
                                icon: Icon(
                                  _hiddenPass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: AppColor.abu,
                                ),
                              ),
                            ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _lupaPassword,
                          child: Text(
                            'Lupa Password?',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.biru,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: _yellowButton(
                          'Log in',
                          _loading ? null : _login,
                          loading: _loading,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(child: _yellowButton('Sign in', _signIn)),
                    ],
                  ),
                ),
                const SizedBox(height: 150),
                Image.asset(
                  'assets/images/LokaTrip-logo-no-van.png',
                  width: 90,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.ungu.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.ungu, width: 1.5),
      ),
    );
  }

  Widget _yellowButton(
    String teks,
    VoidCallback? onPressed, {
    bool loading = false,
  }) {
    return SizedBox(
      width: 200,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.kuning,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.putih,
                ),
              )
            : Text(
                teks,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
