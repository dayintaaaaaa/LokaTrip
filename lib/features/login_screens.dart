import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokatrip/services/auth_service.dart';
import '../core/app_color.dart';
import '../features/register_screens.dart';
import '../features/user/home_screens.dart';

class LoginScreens extends StatefulWidget {
  const LoginScreens({super.key});

  @override
  State<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  final _emailController = TextEditingController(); // email atau nomor telepon
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _login() async {
    final id = _emailController.text.trim();
    final pass = _passwordController.text;

    if (id.isEmpty || pass.isEmpty) {
      _pesan('Email/nomor telepon dan password wajib diisi');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService().login(identifier: id, password: pass);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreens()),
      );
    } on AuthFailure catch (e) {
      _pesan(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _lupaPassword() async {
    final emailCtrl = TextEditingController(
      text: _emailController.text.contains('@')
          ? _emailController.text.trim()
          : '',
    );

    final kirim = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Lupa Password',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan email akunmu. Kami akan mengirim link untuk mengatur ulang password.',
              style: GoogleFonts.manrope(fontSize: 12),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.manrope(fontSize: 12),
              decoration: _inputDecoration('masukkan email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Kirim'),
          ),
        ],
      ),
    );

    if (kirim != true) return;

    final email = emailCtrl.text.trim();
    if (!email.contains('@')) {
      _pesan('Email tidak valid');
      return;
    }

    try {
      await AuthService().forgotPassword(email);
      _pesan('Jika email terdaftar, link reset password sudah dikirim');
    } on AuthFailure catch (e) {
      _pesan(e.message);
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
                      // Email/telephone
                      Text(
                        'Email atau Nomor Telepon',
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
                          'admin@gmail.com atau 0812345678',
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

                      SizedBox(height: 20),

                      // button
                      Center(
                        child: _yellowButton(
                          'Log in',
                          _loading ? null : _login,
                          loading: _loading,
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
            ? SizedBox(
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
