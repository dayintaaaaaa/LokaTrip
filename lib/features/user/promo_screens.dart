import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/promo_data.dart';
import '../../widgets/top_navigator.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/promo_card.dart';
import '../../widgets/promo_flash_card.dart';
import '../../widgets/promo_tur_card.dart';
import 'pembelian_screens.dart';

class PromoScreens extends StatefulWidget {
  const PromoScreens({super.key});

  @override
  State<PromoScreens> createState() => _PromoScreensState();
}

class _PromoScreensState extends State<PromoScreens> {
  int _kota = 0;
  int _kategori = 0;
  String _query = '';
  final _cariC = TextEditingController();

  // countdown flash sale (TODO: ganti dengan waktu berakhir dari backend)
  Duration _sisaWaktu = const Duration(hours: 4, minutes: 18, seconds: 22);
  Timer? _timer;

  static const _daftarKota = [
    'Semua Kota',
    'Bali',
    'Yogyakarta',
    'Malang & Batu',
  ];

  static const _daftarKategori = [
    ('Semua Promo', Icons.confirmation_number_outlined),
    ('Candi & Budaya', Icons.temple_buddhist_outlined),
    ('Waterpark', Icons.pool_outlined),
    ('Taman Hiburan', Icons.attractions_outlined),
    ('Alam', Icons.landscape_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sisaWaktu.inSeconds <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _sisaWaktu -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cariC.dispose();
    super.dispose();
  }

  String _dua(int n) => n.toString().padLeft(2, '0');

  String get _teksTimer =>
      '${_dua(_sisaWaktu.inHours)} : ${_dua(_sisaWaktu.inMinutes % 60)} : ${_dua(_sisaWaktu.inSeconds % 60)}';

  // ================== FILTER ==================
  bool _cocok(PromoItem p) {
    if (_kota != 0 && p.kota != _daftarKota[_kota]) return false;
    if (_kategori != 0 && p.kategori != _daftarKategori[_kategori].$1) {
      return false;
    }
    if (_query.isNotEmpty) {
      final gabungan =
          '${p.judul} ${p.lokasi} ${p.kota} ${p.kategori} ${p.kategoriLokasi}'
              .toLowerCase();
      if (!gabungan.contains(_query)) return false;
    }
    return true;
  }

  List<PromoItem> _ambil(PromoTipe tipe) =>
      daftarPromo.where((p) => p.tipe == tipe && _cocok(p)).toList();

  // ================== AKSI PESAN ==================
  void _pesan(PromoItem p) {
    if (p.tipe == PromoTipe.flash && _sisaWaktu.inSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Flash sale sudah berakhir',
            style: GoogleFonts.manrope(),
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PembelianScreens(item: p)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flash = _ambil(PromoTipe.flash);
    final destinasi = _ambil(PromoTipe.destinasi);
    final tur = _ambil(PromoTipe.tur);
    final kosong = flash.isEmpty && destinasi.isEmpty && tur.isEmpty;

    return Scaffold(
      backgroundColor: AppColor.latar,
      body: SafeArea(
        child: Column(
          children: [
            const TopNavigator(),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchBar(),
                    const SizedBox(height: 12),
                    _chipKota(),
                    const SizedBox(height: 16),

                    if (flash.isNotEmpty) ...[
                      _flashSale(flash),
                      const SizedBox(height: 16),
                    ],

                    _chipKategori(),
                    const SizedBox(height: 18),

                    if (kosong) _stateKosong(),

                    if (destinasi.isNotEmpty) ...[
                      _judulSeksi(
                        'Destinasi Sedang Diskon',
                        'Tiket masuk & wahana terpopuler harga hemat',
                      ),
                      const SizedBox(height: 12),
                      ...destinasi.map(
                        (p) => PromoCard(
                          warnaGambar: p.warna,
                          badgeUtama: p.badgeUtama,
                          badgeKedua: p.badgeKedua,
                          lokasi: p.lokasi,
                          kategoriLokasi: p.kategoriLokasi,
                          judul: p.judul,
                          rating: p.rating,
                          ulasan: p.ulasan,
                          chipInfo: p.chipInfo,
                          fitur: p.fitur,
                          labelHarga: p.labelHarga,
                          hargaCoret: rp(p.hargaCoret),
                          harga: rp(p.harga),
                          satuan: p.satuan,
                          teksTombol: p.teksTombol,
                          onTap: () => _pesan(p),
                        ),
                      ),
                    ],

                    if (tur.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _judulSeksi(
                        'Promo Tur & Petualangan',
                        'Diskon bundling open trip & wahana outdoor',
                      ),
                      const SizedBox(height: 12),
                      ...tur.map(
                        (p) => PromoTurCard(
                          warnaGambar: p.warna,
                          badge: p.badgeUtama,
                          badgeWarna: p.badgeWarna,
                          badgeTeks: p.badgeTeks,
                          kategori: p.kategoriTur,
                          judul: p.judul,
                          deskripsi: p.deskripsi,
                          hargaCoret: rp(p.hargaCoret),
                          harga: rp(p.harga),
                          onTap: () => _pesan(p),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigator(currentIndex: 3),
    );
  }

  // ================== SEARCH ==================
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: AppColor.abu),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _cariC,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              style: GoogleFonts.manrope(fontSize: 12, color: AppColor.hitam),
              decoration: InputDecoration(
                hintText: 'Cari destinasi diskon (cth- Bali, Borobudur)',
                hintStyle:
                    GoogleFonts.manrope(fontSize: 11, color: AppColor.abu),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _cariC.clear();
                setState(() => _query = '');
              },
              child: const Icon(Icons.close, size: 18, color: AppColor.abu),
            ),
        ],
      ),
    );
  }

  // ================== CHIP KOTA ==================
  Widget _chipKota() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _daftarKota.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final aktif = i == _kota;
          return InkWell(
            onTap: () => setState(() => _kota = i),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: aktif ? AppColor.ungu : AppColor.putih,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: aktif
                      ? AppColor.ungu
                      : AppColor.abu.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _daftarKota[i],
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: aktif ? FontWeight.w700 : FontWeight.w600,
                  color: aktif ? AppColor.putih : AppColor.hitam,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================== FLASH SALE ==================
  Widget _flashSale(List<PromoItem> daftar) {
    final berakhir = _sisaWaktu.inSeconds <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.kuning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt,
                      size: 18, color: AppColor.kuning),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flash Sale Wisata Kilat',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColor.hitam,
                        ),
                      ),
                      Text(
                        berakhir
                            ? 'Flash sale telah berakhir'
                            : 'Harga termurah terbatas jam ini',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          color: AppColor.abu,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: berakhir
                        ? AppColor.abu.withValues(alpha: 0.3)
                        : AppColor.kuning,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 12, color: AppColor.ungu),
                      const SizedBox(width: 4),
                      Text(
                        _teksTimer,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColor.ungu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 310,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: daftar
                  .map(
                    (p) => PromoFlashCard(
                      warnaGambar: p.warna,
                      badge: p.badgeUtama,
                      lokasi: p.lokasi,
                      judul: p.judul,
                      rating: p.rating,
                      ulasan: p.ulasan,
                      harga: rp(p.harga),
                      hargaCoret: rp(p.hargaCoret),
                      sisaTiket: p.sisaTiket,
                      persenTerjual: p.persenTerjual,
                      onTap: () => _pesan(p),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ================== CHIP KATEGORI ==================
  Widget _chipKategori() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _daftarKategori.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final aktif = i == _kategori;
          final (label, icon) = _daftarKategori[i];
          return InkWell(
            onTap: () => setState(() => _kategori = i),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: aktif ? AppColor.ungu : AppColor.putih,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: aktif
                      ? AppColor.ungu
                      : AppColor.abu.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 14,
                      color: aktif ? AppColor.putih : AppColor.ungu),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: aktif ? FontWeight.w700 : FontWeight.w600,
                      color: aktif ? AppColor.putih : AppColor.hitam,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================== KOSONG ==================
  Widget _stateKosong() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off,
                size: 40, color: AppColor.abu.withValues(alpha: 0.6)),
            const SizedBox(height: 10),
            Text(
              'Belum ada promo yang cocok',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColor.hitam,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba ganti kota, kategori, atau kata kunci pencarian.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
            ),
          ],
        ),
      ),
    );
  }

  // ================== JUDUL SEKSI ==================
  Widget _judulSeksi(String judul, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          judul,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColor.hitam,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
        ),
      ],
    );
  }
}