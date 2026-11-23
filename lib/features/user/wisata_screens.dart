import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_color.dart';
import '../../models/wisata.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/top_navigator.dart';
import 'home_widgets/kategori_wisata.dart';
import 'wisata_widgets/katalog_wisata.dart';
import 'wisata_widgets/pilih_kota.dart';
import 'wisata_widgets/sub_top_bar.dart';
import 'wisata_widgets/terpopuler_wisata.dart';
import '../../services/wisata_service.dart';

class WisataScreens extends StatefulWidget {
  const WisataScreens({super.key});

  @override
  State<WisataScreens> createState() => _WisataScreensState();
}

class _WisataScreensState extends State<WisataScreens> {
  static const _latar = AppColor.putih;

  String? _kota; // null = semua lokasi

  final _service = WisataService();
  List<Wisata> _semua = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getSemua();
      if (!mounted) return;
      setState(() {
        _semua = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat wisata: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // semua kota yang ada di data halaman ini
  List<String> get _daftarKota {
    final kota = _semua.map((w) => w.kota).whereType<String>().toSet().toList();
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
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Gagal memuat data wisata'),
                          TextButton(
                            onPressed: _muat,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _muat,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // kategori
                            _panel(
                              child: const KategoriWisata(
                                tampilJudul: false,
                                maxBaris: 2,
                              ),
                            ),

                            // destinasi terpopuler (data asli)
                            _panel(
                              child: TerpopulerWisata(
                                daftar: _saring(_semua).take(10).toList(),
                              ),
                            ),

                            // katalog wisata pilihan (data asli)
                            _panel(
                              child: KatalogWisata(daftar: _saring(_semua)),
                            ),
                          ],
                        ),
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
