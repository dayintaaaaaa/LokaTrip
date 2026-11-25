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
  bool _hiddenUlang = true;
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
            stops: [0, 0.45, 0.8],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Text(
                        'Atur Password Baru',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColor.putih,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Buat password baru untuk mengamankan akunmu.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: AppColor.putih,
                        ),
                      ),
                      const SizedBox(height: 42),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
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
                            _label('Password baru'),
                            TextField(
                              controller: _passBaru,
                              obscureText: _hidden,
                              style: GoogleFonts.manrope(fontSize: 12),
                              decoration: _dekor('masukkan password baru')
                                  .copyWith(
                                    suffixIcon: IconButton(
                                      onPressed: () =>
                                          setState(() => _hidden = !_hidden),
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
                            const SizedBox(height: 16),
                            _label('Ulangi password baru'),
                            TextField(
                              controller: _passUlang,
                              obscureText: _hiddenUlang,
                              style: GoogleFonts.manrope(fontSize: 12),
                              decoration: _dekor('ulangi password baru')
                                  .copyWith(
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(
                                        () => _hiddenUlang = !_hiddenUlang,
                                      ),
                                      icon: Icon(
                                        _hiddenUlang
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 18,
                                        color: AppColor.abu,
                                      ),
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: SizedBox(
                                width: 220,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _simpan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.kuning,
                                    foregroundColor: AppColor.putih,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColor.putih,
                                          ),
                                        )
                                      : Text(
                                          'Simpan',
                                          style: GoogleFonts.manrope(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                            ),
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
          ),
        ),
      ),
    );
  }

  Widget _label(String teks) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
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
