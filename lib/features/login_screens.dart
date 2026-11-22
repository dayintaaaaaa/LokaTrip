import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/api_client.dart';
import '../core/app_color.dart';
import '../core/session_manager.dart';
import '../features/register_screens.dart';
import 'admin/dashboard_admin_screens.dart';
import 'admin_mitra/wisata_saya_mitra_screen.dart';
import '../features/user/home_screens.dart';

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

  Future<void> _login() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final identifier = _emailController.text.trim();
      final password = _passwordController.text;
      if (identifier.isEmpty || password.isEmpty) {
        throw const ApiException('Email/username dan password wajib diisi.');
      }

      // Non-email identifiers (username or legacy phone number) are resolved
      // by the Supabase Edge Function, which keeps lookup credentials server-side.
      if (!identifier.contains('@')) {
        final response = await Supabase.instance.client.functions.invoke(
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
        final role = payload['role'] as String?;
        if (accessToken == null || refreshToken == null) {
          throw const ApiException('Sesi login tidak valid.');
        }
        final restored = await Supabase.instance.client.auth.setSession(
          refreshToken,
        );
        final activeSession = restored.session;
        if (activeSession == null) {
          throw const ApiException('Sesi login tidak dapat diaktifkan.');
        }
        var resolvedRole = role;
        // The currently deployed phone-login function predates role routing.
        // Infer the role from the authenticated profile until its update lands.
        if (resolvedRole == null) {
          final authUser = restored.user;
          if (authUser == null) {
            throw const ApiException('Profil login tidak dapat dibaca.');
          }
          final admin = await Supabase.instance.client
              .from('admin_lokatrip')
              .select('id_admin')
              .eq('auth_id', authUser.id)
              .maybeSingle();
          if (admin != null) {
            resolvedRole = 'admin';
          } else {
            final mitra = await Supabase.instance.client
                .from('admin_wisata')
                .select('id_mitra')
                .eq('email', authUser.email!)
                .maybeSingle();
            if (mitra != null) {
              resolvedRole = 'mitra';
            } else {
              final profile = await Supabase.instance.client
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

      final client = Supabase.instance.client;
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

      final mitra = await client
          .from('admin_wisata')
          .select('id_mitra')
          .eq('email', user.email!)
          .maybeSingle();
      if (mitra != null) {
        await SessionManager.setMitraSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
        if (mounted) _openHome(const WisataSayaMitraScreen());
        return;
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
      _showMessage(error.message);
    } on AuthException catch (error) {
      _showMessage(error.message);
    } on PostgrestException catch (error) {
      await Supabase.instance.client.auth.signOut();
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Login gagal: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openHome(Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
      (_) => false,
    );
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.ungu, AppColor.biru, AppColor.putih],
            stops: [0.0, 0.45, 0.8],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 60),

                // title
                Text(
                  'Login',
                  style: GoogleFonts.outfit(
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                    color: AppColor.putih,
                  ),
                ),

                SizedBox(height: 10),

                // sub title
                Text(
                  'Jelajahi destinasi impianmu dengan kami.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: AppColor.putih,
                  ),
                ),

                SizedBox(height: 100),

                // card form
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 24, 24, 28),
                  decoration: BoxDecoration(
                    color: AppColor.putih,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.hitam.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      // Email/telephone
                      Text(
                        'Email atau username',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.hitam,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.manrope(fontSize: 12),
                        decoration: _inputDecoration(
                          'email@contoh.com atau nama pengguna',
                        ),
                      ),

                      SizedBox(height: 15),

                      // password
                      Text(
                        'Password',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.hitam,
                        ),
                      ),
                      SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _hiddenPass,
                        style: GoogleFonts.manrope(fontSize: 12),
                        decoration: _inputDecoration('masukkan password')
                            .copyWith(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hiddenPass = !_hiddenPass;
                                  });
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

                      // forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
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

                      SizedBox(height: 20),

                      // button
                      Center(
                        child: _yellowButton(
                          _loading ? 'Memproses…' : 'Log in',
                          _login,
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(child: _yellowButton('Sign in', _signIn)),
                    ],
                  ),
                ),

                SizedBox(height: 150),

                // logo
                Image.asset(
                  'assets/images/LokaTrip-logo-no-van.png',
                  width: 90,
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gaya field input (dipakai email & password)
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

  // Tombol kuning bulat (dipakai Log in & Sign in)
  Widget _yellowButton(String teks, VoidCallback onPressed) {
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
        child: Text(
          teks,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
