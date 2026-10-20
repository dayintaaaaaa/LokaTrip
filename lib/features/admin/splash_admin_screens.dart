import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/session_manager.dart';
import 'login_admin_screens.dart';
import 'profil_screens.dart';

class SplashAdminScreens extends StatefulWidget {
  const SplashAdminScreens({super.key});

  @override
  State<SplashAdminScreens> createState() => _SplashAdminScreensState();
}

class _SplashAdminScreensState extends State<SplashAdminScreens>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final loggedIn = await SessionManager.isLoggedIn();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                loggedIn ? const ProfilAdminScreens() : const LoginAdminScreens(),
          ),
        );
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            colors: [Color(0xFFF1F7FC), AppColor.putih],
          ),
        ),
        child: Stack(
          children: [
            // road
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SvgPicture.asset(
                'assets/images/Roud-Horizontal-Line.svg',
                fit: BoxFit.fitWidth,
              ),
            ),

            // cloud kiri
            Positioned(
              top: 80,
              left: 24,
              child: SvgPicture.asset(
                'assets/images/Simple-Cloud.svg',
                width: 70,
              ),
            ),

            // cloud kanan
            Positioned(
              top: 100,
              right: 15,
              child: SvgPicture.asset(
                'assets/images/Simple-Cloud.svg',
                width: 90,
              ),
            ),

            // Badge ADMIN kanan atas
            Positioned(
              top: 52,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.ungu,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded,
                        size: 11, color: AppColor.putih),
                    const SizedBox(width: 4),
                    Text(
                      'ADMIN',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColor.putih,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // main content
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/Campervan.svg',
                          width: 300,
                        ),
                        const SizedBox(height: 12),
                        Image.asset(
                          'assets/images/LokaTrip-logo-no-van.png',
                          width: 200,
                        ),
                        const SizedBox(height: 9),
                        Text(
                          'Enterprise Admin Platform',
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.hitam,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // loading bar bawah
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _controller.value,
                                minHeight: 4,
                                color: AppColor.ungu,
                                backgroundColor:
                                    AppColor.ungu.withValues(alpha: 0.15),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.biru,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Memuat panel administrasi...',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: AppColor.abu,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'v2.4.0 Enterprise',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
