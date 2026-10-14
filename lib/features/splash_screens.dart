import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';
import '../core/session_manager.dart';
import '../features/login_screens.dart';
import '../features/user/home_screens.dart';

class SplashScreens extends StatefulWidget {
  const SplashScreens({super.key});

  @override
  State<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // setelah loading, lanjut ke home screen
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        final loggedIn = await SessionManager.isLoggedIn();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                loggedIn ? const HomeScreens() : const LoginScreens(),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFF1F7FC), AppColor.putih],
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

            // left top cloud
            Positioned(
              top: 80,
              left: 24,
              child: SvgPicture.asset(
                'assets/images/Simple-Cloud.svg',
                width: 70,
              ),
            ),

            // right top cloud
            Positioned(
              top: 100,
              right: 15,
              child: SvgPicture.asset(
                'assets/images/Simple-Cloud.svg',
                width: 90,
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
                        SizedBox(height: 12),
                        Image.asset(
                          'assets/images/LokaTrip-logo-no-van.png',
                          width: 200,
                        ),
                        SizedBox(height: 9),
                        Text(
                          'Jelajahi Wisata Nusantara',
                          style: GoogleFonts.rubik(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.hitam,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // loading bawah
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
                        SizedBox(height: 12),
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
                            SizedBox(width: 8),
                            Text(
                              'Menyiapkan petualanganmu...',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: AppColor.abu,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'v1.0.0 Prototype',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                        SizedBox(height: 24),
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