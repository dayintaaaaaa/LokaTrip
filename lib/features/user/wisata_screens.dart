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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rows = await UserApi.catalog();
      if (!mounted) return;

      setState(() {
        _wisata = rows.map(Wisata.fromApiJson).toList(growable: false);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<String> get _daftarKota {
    final kota =
        _wisata
            .map((wisata) => wisata.kota)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

    return kota;
  }

  List<Wisata> _saring(List<Wisata> daftar) {
    if (_kota == null) return daftar;
    return daftar.where((wisata) => wisata.kota == _kota).toList();
  }

  Future<void> _pilihKota() async {
    final hasil = await tampilkanPilihKota(
      context,
      daftar: _daftarKota,
      terpilih: _kota,
    );

    if (!mounted || hasil == null) return;
    setState(() => _kota = hasil == kotaSemua ? null : hasil);
  }

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
    final terpopuler = _saring(_wisata).toList()
      ..sort((a, b) {
        final bandingRating = (b.rating ?? 0).compareTo(a.rating ?? 0);
        if (bandingRating != 0) return bandingRating;

        return (b.jumlahUlasan ?? 0).compareTo(a.jumlahUlasan ?? 0);
      });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _latar,
        body: Column(
          children: [
            const TopNavigator(),
            SubTopBar(
              lokasi: _kota ?? 'Semua Lokasi',
              onLokasiTap: _pilihKota,
              onSubmitted: (kata) {
                // TODO: buka hasil pencarian.
              },
              onFilterTap: () {
                // TODO: buka filter.
              },
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Gagal memuat data wisata'),
                            const SizedBox(height: 8),
                            Text(_error!, textAlign: TextAlign.center),
                            TextButton(
                              onPressed: _muatWisata,
                              child: const Text('Coba lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _muatWisata,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _panel(
                              child: const KategoriWisata(
                                tampilJudul: false,
                                maxBaris: 2,
                              ),
                            ),
                            _panel(
                              child: TerpopulerWisata(
                                daftar: terpopuler.take(10).toList(),
                              ),
                            ),
                            _panel(
                              child: KatalogWisata(daftar: _saring(_wisata)),
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
