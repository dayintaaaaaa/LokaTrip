import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final String initialQuery;
  final bool bukaFilterOtomatis;

  const WisataScreens({
    super.key,
    this.initialQuery = '',
    this.bukaFilterOtomatis = false,
  });

  @override
  State<WisataScreens> createState() => _WisataScreensState();
}

class _WisataScreensState extends State<WisataScreens> {
  static const _latar = AppColor.putih;

  String? _kota; // null = semua lokasi
  final _cariController = TextEditingController();
  String _kata = '';
  bool _ratingTinggi = false;
  bool _konfirmasiInstan = false;
  bool _urutTerlaris = false;
  List<Wisata> _wisata = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _kata = widget.initialQuery.trim();
    _cariController.text = _kata;
    _muatWisata();
    if (widget.bukaFilterOtomatis) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _bukaFilter();
      });
    }
  }

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
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

  List<Wisata> get _hasil {
    final kata = _kata.trim().toLowerCase();
    final hasil = _wisata.where((w) {
      final cocokKota = _kota == null || w.kota == _kota;
      final cocokRating = !_ratingTinggi || (w.rating ?? 0) >= 4.8;
      final cocokInstan =
          !_konfirmasiInstan ||
          w.fitur.any((fitur) => fitur.toLowerCase().contains('instan'));
      final teks = <String>[
        w.nama,
        w.lokasi,
        w.kota ?? '',
        w.kategori ?? '',
        ...w.kategoriLain,
        w.jenis ?? '',
        w.subkategori ?? '',
        w.tipe ?? '',
        ...w.fitur,
      ].join(' ').toLowerCase();
      final cocokKata =
          kata.isEmpty || kata.split(RegExp(r'\s+')).every(teks.contains);
      return cocokKota && cocokRating && cocokInstan && cocokKata;
    }).toList();

    if (_urutTerlaris) {
      hasil.sort(
        (a, b) => (b.jumlahUlasan ?? 0).compareTo(a.jumlahUlasan ?? 0),
      );
    }
    return hasil;
  }

  bool get _adaPenyaring =>
      _kota != null ||
      _kata.isNotEmpty ||
      _ratingTinggi ||
      _konfirmasiInstan ||
      _urutTerlaris;

  Future<void> _bukaFilter() async {
    var rating = _ratingTinggi;
    var instan = _konfirmasiInstan;
    var terlaris = _urutTerlaris;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: AppColor.latar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.ungu.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.ungu.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColor.ungu,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Atur filter wisata',
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: AppColor.hitam,
                            ),
                          ),
                          Text(
                            'Pilih kriteria yang sesuai dengan trip kamu.',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: AppColor.abu,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _barisFilter(
                  ikon: Icons.star_rounded,
                  warnaIkon: AppColor.kuning,
                  judul: 'Rating 4,8 ke atas',
                  deskripsi: 'Tampilkan wisata dengan ulasan terbaik.',
                  aktif: rating,
                  onTap: () => setSheetState(() => rating = !rating),
                ),
                const SizedBox(height: 9),
                _barisFilter(
                  ikon: Icons.bolt_rounded,
                  warnaIkon: AppColor.biru,
                  judul: 'Konfirmasi instan',
                  deskripsi:
                      'Tiket terkonfirmasi otomatis setelah pembayaran berhasil.',
                  aktif: instan,
                  onTap: () => setSheetState(() => instan = !instan),
                ),
                const SizedBox(height: 9),
                _barisFilter(
                  ikon: Icons.sort_rounded,
                  warnaIkon: AppColor.ungu,
                  judul: 'Paling banyak diulas',
                  deskripsi: 'Urutkan wisata dengan jumlah ulasan terbanyak.',
                  aktif: terlaris,
                  onTap: () => setSheetState(() => terlaris = !terlaris),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setSheetState(() {
                          rating = false;
                          instan = false;
                          terlaris = false;
                        }),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.ungu,
                          side: BorderSide(
                            color: AppColor.ungu.withValues(alpha: 0.35),
                          ),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _ratingTinggi = rating;
                            _konfirmasiInstan = instan;
                            _urutTerlaris = terlaris;
                          });
                          Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.ungu,
                          foregroundColor: AppColor.putih,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Terapkan filter',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _barisFilter({
    required IconData ikon,
    required Color warnaIkon,
    required String judul,
    required String deskripsi,
    required bool aktif,
    required VoidCallback onTap,
  }) {
    return Material(
      color: aktif ? AppColor.ungu.withValues(alpha: 0.07) : AppColor.putih,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: aktif
                  ? AppColor.ungu.withValues(alpha: 0.45)
                  : AppColor.abu.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: warnaIkon.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(ikon, color: warnaIkon, size: 19),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      deskripsi,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        height: 1.3,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: aktif ? AppColor.ungu : AppColor.putih,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: aktif
                        ? AppColor.ungu
                        : AppColor.abu.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: aktif
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: AppColor.putih,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
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
    final hasil = _hasil;
    final terpopuler = _wisata.toList()
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
              controller: _cariController,
              onChanged: (kata) => setState(() => _kata = kata),
              onSubmitted: (kata) => setState(() => _kata = kata.trim()),
              onFilterTap: _bukaFilter,
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
                          children: _adaPenyaring
                              ? [
                                  _panel(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${hasil.length} wisata ditemukan',
                                              style: GoogleFonts.manrope(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: AppColor.hitam,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _kata = '';
                                                _kota = null;
                                                _cariController.clear();
                                                _ratingTinggi = false;
                                                _konfirmasiInstan = false;
                                                _urutTerlaris = false;
                                              });
                                            },
                                            child: const Text('Hapus filter'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _panel(
                                    child: hasil.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(36),
                                            child: Center(
                                              child: Text(
                                                'Wisata tidak ditemukan. Coba kata kunci atau filter lain.',
                                              ),
                                            ),
                                          )
                                        : KatalogWisata(daftar: hasil),
                                  ),
                                ]
                              : [
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
                                  _panel(child: KatalogWisata(daftar: _wisata)),
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
