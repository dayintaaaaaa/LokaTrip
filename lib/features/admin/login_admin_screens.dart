import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/session_manager.dart';
import 'profil_screens.dart';
import 'register_admin_screens.dart';

class LoginAdminScreens extends StatefulWidget {
  const LoginAdminScreens({super.key});

  @override
  State<LoginAdminScreens> createState() => _LoginAdminScreensState();
}

class _LoginAdminScreensState extends State<LoginAdminScreens> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hiddenPass = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // TODO: ganti dengan autentikasi admin sungguhan (cek ke backend)
    await SessionManager.setLoggedIn();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfilAdminScreens()),
    );
  }

  void _keRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterAdminScreens()),
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
            colors: [
              AppColor.ungu,
              AppColor.biru,
              AppColor.putih,
            ],
            stops: [0.0, 0.45, 0.8],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Badge ADMIN
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.putih.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColor.putih.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded,
                          size: 14, color: AppColor.putih),
                      const SizedBox(width: 6),
                      Text(
                        'LOKATRIP ADMIN PANEL',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColor.putih,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Judul
                Text(
                  'Admin Login',
                  style: GoogleFonts.outfit(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: AppColor.putih,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Masuk ke panel administrasi LokaTrip.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColor.putih.withValues(alpha: 0.85),
                  ),
                ),

                const SizedBox(height: 40),

                // Card form
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
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
                      // Email dinas
                      Text(
                        'Email Dinas',
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
                        decoration: _inputDecoration('admin@lokatrip.id'),
                      ),

                      const SizedBox(height: 16),

                      // Password
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
                        decoration: _inputDecoration('masukkan password').copyWith(
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

                      // Lupa password
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

                      const SizedBox(height: 8),

                      // Tombol masuk
                      Center(child: _primaryButton('Masuk', _login)),
                      const SizedBox(height: 10),
                      Center(child: _secondaryButton('Daftar Admin', _keRegister)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Footer info keamanan
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColor.ungu.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 12, color: AppColor.ungu),
                      const SizedBox(width: 6),
                      Text(
                        'Dilindungi enkripsi TLS 1.3',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: AppColor.ungu,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Image.asset('assets/images/LokaTrip-logo-no-van.png', width: 90),

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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColor.ungu.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColor.ungu, width: 1.5),
      ),
    );
  }

  Widget _primaryButton(String teks, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.kuning,
          foregroundColor: AppColor.putih,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          teks,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(String teks, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.ungu,
          side: const BorderSide(color: AppColor.ungu, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          teks,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
