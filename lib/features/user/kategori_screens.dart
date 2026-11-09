import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../models/kategori.dart';
import '../../models/wisata.dart';
import '../../models/wisata_dummy.dart';
import '../../widgets/bottom_navigator.dart';
import 'kategori_widgets/banner_kategori.dart';
import 'kategori_widgets/kartu_kategori.dart';
import 'kategori_widgets/kartu_atraksi.dart';
import 'kategori_widgets/kartu_tur.dart';
import 'kategori_widgets/kartu_layanan.dart';

class KategoriScreens extends StatefulWidget {
  final Kategori kategori;

  const KategoriScreens({super.key, required this.kategori});

  @override
  State<KategoriScreens> createState() => _KategoriScreensState();
}

class _KategoriScreensState extends State<KategoriScreens> {
  static const _latar = Color(0xFFF5F6FA);

  final _cariController = TextEditingController();

  String? _jenis; // null = semua jenis
  bool _mencari = false;
  String _kata = '';

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  // semua wisata di kategori ini
  List<Wisata> get _daftarKategori => WisataDummy.semuaWisata
      .where(
        (w) =>
            w.kategori == widget.kategori.nama ||
            w.kategoriLain.contains(widget.kategori.nama),
      )
      .toList();

  // chip jenis dibuat otomatis dari data (urutan sesuai kemunculan)
  List<String> get _daftarJenis =>
      _daftarKategori.map((w) => w.jenis).whereType<String>().toSet().toList();

  List<Wisata> get _hasil {
    final kunci = _kata.trim().toLowerCase();
    return _daftarKategori.where((w) {
      final cocokJenis = _jenis == null || w.jenis == _jenis;
      final cocokKata =
          kunci.isEmpty ||
          w.nama.toLowerCase().contains(kunci) ||
          w.lokasi.toLowerCase().contains(kunci);
      return cocokJenis && cocokKata;
    }).toList();
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
    final jenis = _daftarJenis;
    final promo = WisataDummy.promoKategori[widget.kategori.nama];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _latar,
        body: Column(
          children: [
            // header + chip (tetap diam di atas)
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
                    if (jenis.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _barisJenis(jenis),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // isi: banner + daftar kartu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  if (promo != null && _jenis == null && _kata.isEmpty) ...[
                    BannerKategori(promo: promo),
                    const SizedBox(height: 14),
                  ],
                  if (hasil.isEmpty)
                    _kosong()
                  else
                    for (final w in hasil)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _kartu(w),
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

  // gaya kartu per kategori; yang tidak terdaftar memakai gaya Candi
   // gaya kartu per kategori; yang tidak terdaftar memakai gaya Candi
  static const _kartuLokasiDiBawah = {'Atraksi & Rekreasi'};
  static const _kartuTur = {'Tur & Open Trip'};
  static const _diskonSebagaiOff = {'Waterpark & Kolam'};

  Widget _kartu(Wisata w) {
    void bukaDetail() {
      // nanti: buka halaman Detail Wisata
    }

    final nama = widget.kategori.nama;

    if (_kartuLokasiDiBawah.contains(nama)) {
      return KartuAtraksi(wisata: w, onTap: bukaDetail);
    }
    if (_kartuTur.contains(nama)) {
      return KartuTur(wisata: w, onTap: bukaDetail);
    }
    if (nama == 'Playground') {
      return KartuLayanan(wisata: w, onTap: bukaDetail, labelTombol: 'Pilih');
    }
    if (nama == 'Spa & Pijat') {
      return KartuLayanan(wisata: w, onTap: bukaDetail, panahTombol: true);
    }
    if (nama == 'Alam & Outbound') {
      return KartuLayanan(
        wisata: w,
        onTap: bukaDetail,
        subkategoriDiGambar: true,
      );
    }
    return KartuKategori(
      wisata: w,
      onTap: bukaDetail,
      diskonOff: _diskonSebagaiOff.contains(nama),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: AppColor.hitam),
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
                      hintText: 'Cari di ${widget.kategori.judulHalaman}...',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColor.abu,
                      ),
                    ),
                  )
                : Text(
                    widget.kategori.judulHalaman,
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

  Widget _barisJenis(List<String> jenis) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: jenis.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _chip(
              'Semua',
              _jenis == null,
              () => setState(() => _jenis = null),
            );
          }
          final nama = jenis[i - 1];
          return _chip(
            nama,
            _jenis == nama,
            () => setState(() => _jenis = nama),
          );
        },
      ),
    );
  }

  Widget _chip(String label, bool aktif, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: aktif ? AppColor.ungu : AppColor.putih,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: aktif ? AppColor.ungu : AppColor.abu.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: aktif ? AppColor.putih : AppColor.hitam,
          ),
        ),
      ),
    );
  }

  Widget _kosong() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 40, color: AppColor.abu),
          const SizedBox(height: 8),
          Text(
            'Belum ada wisata di kategori ini',
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
