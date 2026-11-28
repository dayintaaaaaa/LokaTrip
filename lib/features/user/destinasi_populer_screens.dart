
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_client.dart';
import '../../core/app_color.dart';
import '../../core/lokasi_malang_raya.dart';
import '../../core/navigasi_wisata.dart';
import '../../models/wisata.dart';
import '../../widgets/bottom_navigator.dart';
import 'destinasi_widgets/kartu_destinasi.dart';

class DestinasiPopulerScreens extends StatefulWidget {
  const DestinasiPopulerScreens({super.key});

  @override
  State<DestinasiPopulerScreens> createState() =>
      _DestinasiPopulerScreensState();
}

class _DestinasiPopulerScreensState extends State<DestinasiPopulerScreens> {
  static const _latar = Color(0xFFF5F6FA);

  final _cariController = TextEditingController();

  String? _kota;
  bool _laris = true;
  bool _rating = false;
  bool _instan = false;
  bool _mencari = false;
  String _kata = '';

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
        _wisata = rows.map(Wisata.fromApiJson).toList();
        _loading = false;
      });
    } catch (error) {
      debugPrint('Gagal memuat destinasi: $error');

      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  // Lokasi filter sama dengan katalog utama.
  List<String> get _daftarKota => LokasiMalangRaya.kota;

  // Menerapkan pencarian dan seluruh filter destinasi.
  List<Wisata> get _hasil {
    final kunci = _kata.trim().toLowerCase();

    final hasil = _wisata.where((w) {
      final cocokKota = _kota == null || w.kota == _kota;
      final cocokRating = !_rating || (w.rating ?? 0) >= 4.8;
      final cocokInstan =
          !_instan || w.fitur.contains('Konfirmasi Instan');

      final cocokKata =
          kunci.isEmpty ||
          w.nama.toLowerCase().contains(kunci) ||
          w.lokasi.toLowerCase().contains(kunci);

      return cocokKota &&
          cocokRating &&
          cocokInstan &&
          cocokKata;
    }).toList();

    // Urutkan dari jumlah ulasan terbanyak.
    if (_laris) {
      hasil.sort((a, b) {
        final c = (b.jumlahUlasan ?? 0).compareTo(a.jumlahUlasan ?? 0);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    }

    return hasil;
  }

  void _bukaTutupCari() {
    setState(() {
      _mencari = !_mencari;

      if (!_mencari) {
        _kata = '';
        _cariController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _hasil;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _latar,
        body: Column(
          children: [
            // Header dan filter tetap berada di bagian atas.
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColor.putih,
                border: Border(
                  bottom: BorderSide(
                    color: AppColor.abu.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _header(),
                    const SizedBox(height: 6),
                    _barisKota(),
                    const SizedBox(height: 8),
                    _barisFilter(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Daftar kartu destinasi.
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 40,
                                color: AppColor.abu,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gagal memuat data wisata',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.abu,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _muatWisata,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        )
                      : hasil.isEmpty
                          ? _kosong()
                          : RefreshIndicator(
                              onRefresh: _muatWisata,
                              child: ListView.separated(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  20,
                                ),
                                itemCount: hasil.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (_, i) => KartuDestinasi(
                                  wisata: hasil[i],
                                  onTap: () =>
                                      bukaDetailWisata(context, hasil[i]),
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

  Widget _header() {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: AppColor.hitam,
            ),
          ),
          Expanded(
            child: _mencari
                ? TextField(
                    controller: _cariController,
                    autofocus: true,
                    onChanged: (v) => setState(() => _kata = v),
                    style: GoogleFonts.manrope(fontSize: 13),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Cari destinasi...',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColor.abu,
                      ),
                    ),
                  )
                : Text(
                    'Destinasi Terpopuler',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
          ),
          IconButton(
            onPressed: _bukaTutupCari,
            icon: Icon(
              _mencari ? Icons.close : Icons.search,
              color: AppColor.hitam,
            ),
          ),
        ],
      ),
    );
  }

  // Chip kota dibuat otomatis dari data.
  Widget _barisKota() {
    final kota = _daftarKota;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kota.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _chipKota(
              'Semua Lokasi',
              _kota == null,
              () => setState(() => _kota = null),
              denganIkon: true,
            );
          }

          final nama = kota[i - 1];

          return _chipKota(
            nama,
            _kota == nama,
            () => setState(() => _kota = nama),
          );
        },
      ),
    );
  }

  // Filter yang bisa dinyalakan dan dimatikan.
  Widget _barisFilter() {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chipFilter(
            Icons.local_fire_department_rounded,
            const Color(0xFFE5842E),
            'Paling Laris',
            _laris,
            () => setState(() => _laris = !_laris),
          ),
          const SizedBox(width: 8),
          _chipFilter(
            Icons.star_rounded,
            AppColor.kuning,
            'Rating 4.8+',
            _rating,
            () => setState(() => _rating = !_rating),
          ),
          const SizedBox(width: 8),
          _chipFilter(
            Icons.check_circle_outline,
            AppColor.ungu,
            'Konfirmasi Instan',
            _instan,
            () => setState(() => _instan = !_instan),
          ),
        ],
      ),
    );
  }

  Widget _chipKota(
    String label,
    bool aktif,
    VoidCallback onTap, {
    bool denganIkon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aktif ? AppColor.ungu : AppColor.putih,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: aktif
                ? AppColor.ungu
                : AppColor.abu.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (denganIkon) ...[
              Icon(
                Icons.location_on,
                size: 13,
                color: aktif ? AppColor.putih : AppColor.ungu,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: aktif ? AppColor.putih : AppColor.hitam,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipFilter(
    IconData ikon,
    Color warnaIkon,
    String label,
    bool aktif,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aktif
              ? AppColor.ungu.withValues(alpha: 0.08)
              : AppColor.putih,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: aktif
                ? AppColor.ungu
                : AppColor.abu.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ikon,
              size: 14,
              color: warnaIkon,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: aktif ? AppColor.ungu : AppColor.hitam,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kosong() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 40,
            color: AppColor.abu,
          ),
          const SizedBox(height: 8),
          Text(
            'Destinasi tidak ditemukan',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.abu,
            ),
          ),
        ],
      ),
    );
  }
}
