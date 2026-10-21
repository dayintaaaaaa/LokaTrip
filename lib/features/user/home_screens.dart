import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_color.dart';
import '../../models/wisata_dummy.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/top_navigator.dart';
import 'home_widgets/destinasi_populer.dart';
import 'home_widgets/flash_sale_section.dart';
import 'home_widgets/home_header.dart';
import 'home_widgets/jaminan_tiket.dart';
import 'home_widgets/kategori_wisata.dart';
import 'home_widgets/trip_akhir_pekan.dart';


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
            TopNavigator(),

            // konten: bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HomeHeader(),
                    SizedBox(height: 20),
                    KategoriWisata(),
                    SizedBox(height: 24),
                    FlashSaleSection(
                      daftar: WisataDummy.flashSale,
                      berakhirPada: WisataDummy.flashSaleBerakhir,
                    ),
                    SizedBox(height: 24),
                    DestinasiPopuler(daftar: WisataDummy.populer),
                    SizedBox(height: 24),
                    TripAkhirPekan(daftar: WisataDummy.tripAkhirPekan),
                    SizedBox(height: 12),
                    JaminanTiket(),
                    SizedBox(height: 24),
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