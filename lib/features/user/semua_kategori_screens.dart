import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../models/kategori.dart';
import '../../models/promo_kategori.dart';
import '../../models/wisata_dummy.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/gambar_wisata.dart';
import 'home_widgets/section_title.dart';
import 'kategori_screens.dart';
import 'kategori_widgets/banner_kategori.dart';
import 'promo_screens.dart';

class SemuaKategoriScreens extends StatefulWidget {
  const SemuaKategoriScreens({super.key});

  @override
  State<SemuaKategoriScreens> createState() => _SemuaKategoriScreensState();
}

class _SemuaKategoriScreensState extends State<SemuaKategoriScreens> {
  static const _latar = Color(0xFFF5F6FA);
  static const _gelap = Color(0xFF1A1A2E);
  static const _filter = ['Populer', 'Ramah Anak', 'Promo Hari Ini'];

  int _filterAktif = 0;
  String _kata = '';

  // jumlah wisata di kategori (termasuk yang tampil sebagai kategori lain)
  int _jumlah(Kategori k) => WisataDummy.semuaWisata
      .where((w) => w.kategori == k.nama || w.kategoriLain.contains(k.nama))
      .length;

  String _satuan(Kategori k) =>
      k.nama == 'Tur & Open Trip' ? 'Paket Tur' : 'Destinasi';

  // kartu besar di bagian "Kategori Terpopuler"
  List<Kategori> get _tile {
    switch (_filterAktif) {
      case 1:
        return Kategori.daftar.where((k) => k.ramahAnak).toList();
      case 2:
        return Kategori.daftar
            .where((k) => WisataDummy.promoKategori.containsKey(k.nama))
            .toList();
      default:
        return Kategori.daftar.where((k) => k.label != null).toList();
    }
  }

  // baris di "Direktori Kategori", disaring oleh kolom pencarian
  List<Kategori> get _direktori {
    final kunci = _kata.trim().toLowerCase();
    if (kunci.isEmpty) return Kategori.daftar;
    return Kategori.daftar.where((k) {
      return k.nama.toLowerCase().contains(kunci) ||
          k.judulHalaman.toLowerCase().contains(kunci) ||
          (k.subjudul ?? '').toLowerCase().contains(kunci);
    }).toList();
  }

  void _buka(Kategori k) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KategoriScreens(kategori: k)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final direktori = _direktori;
    final mencari = _kata.trim().isNotEmpty;
    final tile = _tile;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _latar,
        body: Column(
          children: [
            // header + pencarian + chip (tetap diam di atas)
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
                    SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back,
                                color: AppColor.hitam),
                          ),
                          Text(
                            'Kategori Wisata',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.hitam,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    _kolomCari(),
                    const SizedBox(height: 10),
                    _barisFilter(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // isi
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                children: [
                  if (!mencari) ...[
                    SectionTitle(
                      judul: _filterAktif == 0
                          ? 'Kategori Terpopuler'
                          : 'Kategori ${_filter[_filterAktif]}',
                      warnaAksen: AppColor.ungu,
                    ),
                    const SizedBox(height: 12),
                    if (tile.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Belum ada kategori untuk pilihan ini',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColor.abu,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tile.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.25,
                          ),
                          itemBuilder: (_, i) => _kartuTile(tile[i]),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // banner promo
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: BannerKategori(
                        promo: const PromoKategori(
                          label: 'SPECIAL LIBURAN SERU',
                          judul: 'Pesta Wisata Nusantara',
                          deskripsi:
                              'Diskon s.d 10% & kuota tiket spesial minggu ini',
                          tombol: 'Cek Promo',
                        ),
                        onTombol: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PromoScreens(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // direktori
                  SectionTitle(
                    judul: 'Direktori Kategori',
                    warnaAksen: AppColor.biru,
                    kanan: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.ungu.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${direktori.length} Kategori Pilihan',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (direktori.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          'Kategori tidak ditemukan',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColor.abu,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.putih,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColor.abu.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < direktori.length; i++) ...[
                              _barisDirektori(direktori[i], i == 0 && !mencari),
                              if (i != direktori.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 66,
                                  color: AppColor.abu.withValues(alpha: 0.2),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavigator(currentIndex: 1),
      ),
    );
  }

  Widget _kolomCari() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.ungu.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: AppColor.abu),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _kata = v),
                style: GoogleFonts.manrope(fontSize: 12),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Cari kategori tiket atau aktivitas seru...',
                  hintStyle: GoogleFonts.manrope(
                    fontSize: 12,
                    color: AppColor.abu,
                  ),
                ),
              ),
            ),
            Icon(Icons.tune, size: 18, color: AppColor.ungu),
          ],
        ),
      ),
    );
  }

  Widget _barisFilter() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filter.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final aktif = i == _filterAktif;
          return GestureDetector(
            onTap: () => setState(() => _filterAktif = i),
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
              child: Text(
                _filter[i],
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: aktif ? AppColor.putih : AppColor.hitam,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // kartu besar berlatar gambar (placeholder sampai gambar tersedia)
  Widget _kartuTile(Kategori k) {
    return GestureDetector(
      onTap: () => _buka(k),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const GambarWisata(),

            // bayangan gelap di bawah supaya teks terbaca
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _gelap.withValues(alpha: 0.05),
                      _gelap.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // label kecil kiri atas
            if (k.label != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColor.putih.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    k.label!,
                    style: GoogleFonts.manrope(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColor.ungu,
                    ),
                  ),
                ),
              ),

            // nama + jumlah
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    k.judulHalaman,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColor.putih,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 10, color: AppColor.putih),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${_jumlah(k)} ${_satuan(k)}',
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            color: AppColor.putih.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 14, color: AppColor.putih),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barisDirektori(Kategori k, bool populer) {
    return InkWell(
      onTap: () => _buka(k),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.ungu.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(k.icon, size: 20, color: AppColor.ungu),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    k.judulHalaman,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  if (k.subjudul != null)
                    Text(
                      k.subjudul!,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                ],
              ),
            ),
            if (populer)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.kuning.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Populer',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF8A5A00),
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppColor.abu),
          ],
        ),
      ),
    );
  }
}