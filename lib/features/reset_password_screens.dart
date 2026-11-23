import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokatrip/services/auth_service.dart';
import '../core/app_color.dart';
import 'user/home_screens.dart';

class ResetPasswordScreens extends StatefulWidget {
  const ResetPasswordScreens({super.key});

  @override
  State<ResetPasswordScreens> createState() => _ResetPasswordScreensState();
}

class _ResetPasswordScreensState extends State<ResetPasswordScreens> {
  final _passBaru = TextEditingController();
  final _passUlang = TextEditingController();
  bool _hidden = true;
  bool _loading = false;

  @override
  void dispose() {
    _passBaru.dispose();
    _passUlang.dispose();
    super.dispose();
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _simpan() async {
    if (_passBaru.text.length < 6) {
      _pesan('Password minimal 6 karakter');
      return;
    }
    if (_passBaru.text != _passUlang.text) {
      _pesan('Konfirmasi password tidak sama');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService().ubahPassword(_passBaru.text);
      AuthService.sedangPulihkanPassword = false;
      _pesan('Password berhasil diubah');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreens()),
        (route) => false,
      );
    } on AuthFailure catch (e) {
      _pesan(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dekor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atur Password Baru',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password baru',
                  style: GoogleFonts.manrope(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _passBaru,
                obscureText: _hidden,
                style: GoogleFonts.manrope(fontSize: 12),
                decoration: _dekor('masukkan password baru').copyWith(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColor.abu,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text('Ulangi password baru',
                  style: GoogleFonts.manrope(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: _passUlang,
                obscureText: _hidden,
                style: GoogleFonts.manrope(fontSize: 12),
                decoration: _dekor('ulangi password baru'),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kuning,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Simpan',
                            style: GoogleFonts.outfit(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}