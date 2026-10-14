import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  void _register() {
    // nanti diganti proses daftar nyang beneran (kirim ke backend)
    _keLogin();
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
                        decoration: _inputDecoration('masukkan usernamem'),
                      ),

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
                        decoration: _inputDecoration('masukkan password').copyWith(
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
                            onPressed: _register, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.kuning,
                              foregroundColor: AppColor.putih,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
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
                Image.asset('assets/images/LokaTrip-logo-no-van.png', width: 90),

                SizedBox(height: 24),
              ],
            ),
          )
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
      hintStyle: GoogleFonts.manrope(
        fontSize: 12,
        color: AppColor.abu,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColor.ungu.withValues(alpha: 0.4)
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColor.ungu,
          width: 1.5
        ),
      ),
    );
  }
}