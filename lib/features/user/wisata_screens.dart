import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/api_client.dart';
import '../../core/app_color.dart';
import '../../models/wisata.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/top_navigator.dart';
import 'home_widgets/kategori_wisata.dart';
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
  List<Wisata> _wisata = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muatWisata();
  }

  Future<void> _muatWisata() async {
    try {
      final rows = await UserApi.catalog();
      if (mounted) setState(() => _wisata = rows.map(Wisata.fromApiJson).toList());
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // semua kota yang ada di data halaman ini
  List<String> get _daftarKota {
    final kota = _wisata.map((w) => w.kota).whereType<String>().toSet().toList();
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    // kategori
                    _panel(
                      child: const KategoriWisata(
                        tampilJudul: false,
                        maxBaris: 2,
                      ),
                    ),

                    // destinasi terpopuler
                    _panel(
                      child: TerpopulerWisata(
                        daftar: (_saring(_wisata).toList()
                          ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0))),
                      ),
                    ),

                    // katalog wisata pilihan
                    _panel(
                      child: KatalogWisata(
                        daftar: _saring(_wisata),
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
