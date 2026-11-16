import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokatrip/services/auth_service.dart';
import '../core/app_color.dart';
import '../features/user/home_screens.dart';
import '../features/login_screens.dart';

class RegisterScreens extends StatefulWidget {
  const RegisterScreens({super.key});

  @override
  State<RegisterScreens> createState() => _RegisterScreensState();
}

class _RegisterScreensState extends State<RegisterScreens> {
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _teleponController = TextEditingController();
  bool _hiddenPass = true;
  bool _loading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  // Pengecekan sederhana sebelum dikirim ke server
  String? _validasi() {
    if (_namaController.text.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    if (_usernameController.text.trim().isEmpty) {
      return 'Username wajib diisi';
    }
    if (!_emailController.text.contains('@')) {
      return 'Email tidak valid';
    }
    if (_passwordController.text.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (_teleponController.text.trim().length < 9) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }

  Future<void> _register() async {
    final error = _validasi();
    if (error != null) {
      _pesan(error);
      return;
    }

    setState(() => _loading = true);
    try {
      final langsungLogin = await AuthService().register(
        namaLengkap: _namaController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        noTelepon: _teleponController.text,
      );

      if (!mounted) return;
      if (langsungLogin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreens()),
        );
      } else {
        _pesan('Berhasil daftar. Cek emailmu untuk konfirmasi.');
        _keLogin();
      }
    } on AuthFailure catch (e) {
      _pesan(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _keLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreens()),
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
                  'Register',
                  style: GoogleFonts.outfit(
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                    color: AppColor.putih,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Buat akun untuk jelajahi destinasi.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: AppColor.putih,
                  ),
                ),

                SizedBox(height: 60),

                // card form
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                      // nama lengkap
                      _label('Nama Lengkap'),
                      TextField(
                        controller: _namaController,
                        textCapitalization: TextCapitalization.words,
                        style: GoogleFonts.manrope(fontSize: 12),
                        decoration: _inputDecoration('masukkan nama lengkap'),
                      ),

                      SizedBox(height: 15),

                      // username
                      _label('Username'),
                      TextField(
                        controller: _usernameController,
                        style: GoogleFonts.manrope(fontSize: 12),
                        decoration: _inputDecoration('masukkan username'),
                      ),

                      SizedBox(height: 15),

                      // email
                      _label('Email'),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.manrope(fontSize: 12),
                        decoration: _inputDecoration('masukkan email'),
                      ),

                      SizedBox(height: 15),

                      // password
                      _label('Password'),
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

                      SizedBox(height: 16),

                      // telepon
                      _label('Nomor Telepon'),
                      TextField(
                        controller: _teleponController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.manrope(fontSize: 12),
                        decoration: _inputDecoration('masukkan nomor telepon'),
                      ),

                      SizedBox(height: 20),

                      // button register
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.kuning,
                              foregroundColor: AppColor.putih,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _loading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColor.putih,
                                    ),
                                  )
                                : Text(
                                    'Sign in',
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // sudah punya akun
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Apakah kamu sudah punya akun?  ',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: AppColor.abu,
                              ),
                            ),
                            GestureDetector(
                              onTap: _keLogin,
                              child: Text(
                                'Login',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.biru,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // Label diatas field
  Widget _label(String teks) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColor.hitam,
        ),
      ),
    );
  }

  // Gaya field input
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.ungu.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.ungu, width: 1.5),
      ),
    );
  }
}
