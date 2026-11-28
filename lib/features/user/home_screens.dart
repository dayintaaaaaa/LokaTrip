import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_color.dart';
import '../../core/favorite_store.dart';
import '../../core/session_manager.dart';
import '../../models/wisata.dart';
import '../../services/wisata_service.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/top_navigator.dart';
import 'home_widgets/destinasi_populer.dart';
import 'home_widgets/home_header.dart';
import 'home_widgets/jaminan_tiket.dart';
import 'home_widgets/kategori_wisata.dart';
import 'home_widgets/trip_akhir_pekan.dart';
import 'ai_trip_screens.dart';
import 'wisata_screens.dart';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  final _service = WisataService();
  List<Wisata> _populer = [];
  List<Wisata> _tripAkhirPekan = [];
  bool _loadingPopuler = true;
  bool _loadingTrip = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    await Future.wait([_muatPopuler(), _muatTripAkhirPekan(), _muatFavorit()]);
  }

  Future<void> _muatFavorit() async {
    final token = await SessionManager.currentUserToken();
    if (token == null || token.isEmpty) return;
    try {
      await FavoritStore.muat(token);
    } catch (e) {
      debugPrint('Gagal memuat wishlist: $e');
    }
  }

  Future<void> _muatPopuler() async {
    try {
      final data = await _service.getTerpopuler(limit: 10);
      if (!mounted) return;
      setState(() {
        _populer = data;
        _loadingPopuler = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat destinasi populer: $e');
      if (!mounted) return;
      setState(() => _loadingPopuler = false);
    }
  }

  Future<void> _muatTripAkhirPekan() async {
    try {
      final data = await _service.getTripAkhirPekan();
      if (!mounted) return;
      setState(() {
        _tripAkhirPekan = data;
        _loadingTrip = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat trip akhir pekan: $e');
      if (!mounted) return;
      setState(() => _loadingTrip = false);
    }
  }

  void _bukaPencarian(String kata) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WisataScreens(initialQuery: kata)),
    );
  }

  void _bukaFilter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WisataScreens(bukaFilterOtomatis: true),
      ),
    );
  }

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
                    HomeHeader(onSearch: _bukaPencarian, onFilter: _bukaFilter),
                    const SizedBox(height: 20),
                    AiTripPromo(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AiTripScreens(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    KategoriWisata(),
                    SizedBox(height: 24),
                    SizedBox(height: 24),

                    // destinasi terpopuler (data asli)
                    if (_loadingPopuler)
                      SizedBox(
                        height: 300,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_populer.isNotEmpty)
                      DestinasiPopuler(daftar: _populer),

                    SizedBox(height: 24),

                    // trip spesial akhir pekan (data asli dari database)
                    if (_loadingTrip)
                      SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      TripAkhirPekan(
                        daftar: _tripAkhirPekan,
                      ),

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
