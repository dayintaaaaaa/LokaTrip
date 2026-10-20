import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_color.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/top_navigator.dart';
import 'home_widgets/home_header.dart';
import 'home_widgets/kategori_wisata.dart';

class HomeScreens extends StatelessWidget {
  const HomeScreens({super.key});

  @override
  Widget build(BuildContext context) {
    // ikon status bar gelap karena latar top bar terang
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColor.putih,
        body: Column(
          children: [
            // top bar: tetap diam di atas
            const TopNavigator(),

            // konten: bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    HomeHeader(),
                    SizedBox(height: 20),
                    KategoriWisata(),
                    SizedBox(height: 24),
                    // nanti: Flash Sale, Destinasi Terpopuler,
                    // Trip Spesial Akhir Pekan, Jaminan Tiket
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavigator(currentIndex: 0),
      ),
    );
  }
}