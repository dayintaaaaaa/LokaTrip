import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/api_client.dart';
import '../../core/app_color.dart';
import '../../models/wisata.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/top_navigator.dart';
import 'home_widgets/destinasi_populer.dart';
import 'home_widgets/home_header.dart';
import 'home_widgets/jaminan_tiket.dart';
import 'home_widgets/kategori_wisata.dart';
import 'home_widgets/trip_akhir_pekan.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  late final Future<List<Wisata>> _catalog = UserApi.catalog().then(
    (rows) => rows.map(Wisata.fromApiJson).toList(growable: false),
  );

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
              child: FutureBuilder<List<Wisata>>(
                future: _catalog,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final wisata = snapshot.data ?? const <Wisata>[];
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        HomeHeader(),
                        SizedBox(height: 20),
                        KategoriWisata(),
                        SizedBox(height: 24),
                        DestinasiPopuler(daftar: wisata.take(8).toList()),
                        SizedBox(height: 24),
                        TripAkhirPekan(daftar: wisata.skip(8).take(8).toList()),
                        SizedBox(height: 12),
                        JaminanTiket(),
                        SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavigator(currentIndex: 0),
      ),
    );
  }
}
