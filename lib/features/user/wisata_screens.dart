import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_color.dart';
import '../../models/wisata.dart';
import '../../models/wisata_dummy.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/top_navigator.dart';
import 'home_widgets/kategori_wisata.dart';
import 'wisata_widgets/banner_promo.dart';
import 'wisata_widgets/flash_sale_kilat.dart';
import 'wisata_widgets/katalog_wisata.dart';
import 'wisata_widgets/pilih_kota.dart';
import 'wisata_widgets/sub_top_bar.dart';
import 'wisata_widgets/terpopuler_wisata.dart';

class WisataScreens extends StatefulWidget {
  const WisataScreens({super.key});

  @override
  State<WisataScreens> createState() => _WisataScreensState();
}

class _WisataScreensState extends State<WisataScreens> {
  static const _latar = AppColor.putih;

  String? _kota; // null = semua lokasi

  // semua kota yang ada di data halaman ini
  List<String> get _daftarKota {
    final semua = [
      ...WisataDummy.flashKilat,
      ...WisataDummy.terpopuler,
      ...WisataDummy.katalog,
    ];
    final kota = semua.map((w) => w.kota).whereType<String>().toSet().toList();
    kota.sort();
    return kota;
  }

  List<Wisata> _saring(List<Wisata> daftar) {
    if (_kota == null) return daftar;
    return daftar.where((w) => w.kota == _kota).toList();
  }

  Future<void> _pilihKota() async {
    final hasil = await tampilkanPilihKota(
      context,
      daftar: _daftarKota,
      terpilih: _kota,
    );
    if (!mounted || hasil == null) return; // ditutup tanpa memilih
    setState(() => _kota = hasil == kotaSemua ? null : hasil);
  }

  // panel putih pembungkus tiap bagian
  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      color: AppColor.putih,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _latar,
        body: Column(
          children: [
            // header: top bar + sub top bar (tetap diam di atas)
            const TopNavigator(),
            SubTopBar(
              lokasi: _kota ?? 'Semua Lokasi',
              onLokasiTap: _pilihKota,
              onSubmitted: (kata) {
                // nanti: buka hasil pencarian
              },
              onFilterTap: () {
                // nanti: buka filter
              },
            ),

            // konten: bisa di-scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // kategori
                    _panel(
                      child: const KategoriWisata(
                        tampilJudul: false,
                        maxBaris: 2,
                      ),
                    ),

                    // banner promo
                    _panel(
                      child: BannerPromo(
                        label: 'LIBUR SEKOLAH SERU',
                        judul: 'Diskon Wisata s.d Rp 150.000',
                        kupon: 'LOKALIBUR',
                        berakhirPada: WisataDummy.bannerBerakhir,
                        onSnkTap: () {
                          // nanti: buka S&K promo
                        },
                      ),
                    ),

                    // flash sale kilat
                    _panel(
                      child: FlashSaleKilat(
                        daftar: _saring(WisataDummy.flashKilat),
                        berakhirPada: WisataDummy.kilatBerakhir,
                      ),
                    ),

                    // destinasi terpopuler
                    _panel(
                      child: TerpopulerWisata(
                        daftar: _saring(WisataDummy.terpopuler),
                      ),
                    ),

                    // katalog wisata pilihan
                    _panel(
                      child: KatalogWisata(
                        daftar: _saring(WisataDummy.katalog),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavigator(currentIndex: 1),
      ),
    );
  }
}