import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format.dart';
import '../../widgets/sub_app_bar.dart';

// TODO: ganti model ini dengan model dari backend
class _Wisata {
  final String judul;
  final String lokasi;
  final String rating;
  final String ulasan;
  final String kategori;
  final String badge; // "Diskon 25%", "Popular Choice", dst
  final Color badgeWarna;
  final Color badgeTeks;
  final String chipInfo; // "Tiket Instan QR", "Konfirmasi Instan", dst
  final IconData chipIcon;
  final int hargaCoret;
  final int harga;
  final Color warnaGambar;
  bool favorit;

  _Wisata({
    required this.judul,
    required this.lokasi,
    required this.rating,
    required this.ulasan,
    required this.kategori,
    required this.badge,
    required this.badgeWarna,
    required this.badgeTeks,
    required this.chipInfo,
    required this.chipIcon,
    required this.hargaCoret,
    required this.harga,
    required this.warnaGambar,
    this.favorit = true,
  });
}

class WishlistScreens extends StatefulWidget {
  const WishlistScreens({super.key});

  @override
  State<WishlistScreens> createState() => _WishlistScreensState();
}

class _WishlistScreensState extends State<WishlistScreens> {
  // TODO: ganti dengan data dari backend
  final List<_Wisata> _daftar = [
    _Wisata(
      judul: 'Candi Borobudur Sunrise Tour',
      lokasi: 'Magelang, Jawa Tengah',
      rating: '4.9',
      ulasan: '2.4k ulasan',
      kategori: 'Budaya & Heritage',
      badge: 'Diskon 25%',
      badgeWarna: AppColor.kuning,
      badgeTeks: AppColor.ungu,
      chipInfo: 'Tiket Instan QR',
      chipIcon: Icons.qr_code_2,
      hargaCoret: 500000,
      harga: 375000,
      warnaGambar: AppColor.kuning,
    ),
    _Wisata(
      judul: 'Nusa Penida Island Tour & Snorkeling',
      lokasi: 'Nusa Penida, Bali',
      rating: '4.8',
      ulasan: '1.8k ulasan',
      kategori: 'Bahari & Snorkel',
      badge: 'Diskon 15%',
      badgeWarna: AppColor.kuning,
      badgeTeks: AppColor.ungu,
      chipInfo: 'Konfirmasi Instan',
      chipIcon: Icons.bolt,
      hargaCoret: 650000,
      harga: 550000,
      warnaGambar: AppColor.biru,
    ),
    _Wisata(
      judul: 'Bromo Milky Way & Sunrise Jeep Tour',
      lokasi: 'Probolinggo, Jawa Timur',
      rating: '4.9',
      ulasan: '3.1k ulasan',
      kategori: 'Alam & Petualangan',
      badge: 'Popular Choice',
      badgeWarna: AppColor.ungu,
      badgeTeks: AppColor.putih,
      chipInfo: 'Tiket Instan QR',
      chipIcon: Icons.qr_code_2,
      hargaCoret: 480000,
      harga: 420000,
      warnaGambar: AppColor.ungu,
    ),
    _Wisata(
      judul: 'Waterbom Bali All-Day Pass',
      lokasi: 'Kuta, Badung, Bali',
      rating: '4.8',
      ulasan: '4.2k ulasan',
      kategori: 'Wahana & Rekreasi',
      badge: 'Diskon 20%',
      badgeWarna: AppColor.kuning,
      badgeTeks: AppColor.ungu,
      chipInfo: 'Konfirmasi Langsung',
      chipIcon: Icons.location_on_outlined,
      hargaCoret: 395000,
      harga: 315000,
      warnaGambar: AppColor.biru,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tersimpan = _daftar.where((w) => w.favorit).length;

    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Wishlist Saya'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Row(
                  children: [
                    Text(
                      'Koleksi Pilihan',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.auto_awesome,
                        size: 12, color: AppColor.kuning),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$tersimpan Wisata Tersimpan',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColor.abu,
                  ),
                ),
                const SizedBox(height: 12),
                ..._daftar.map(_kartu),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartu(_Wisata w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _gambar(w),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColor.ungu),
                    const SizedBox(width: 3),
                    Text(
                      w.lokasi,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rp ${formatAngka(w.hargaCoret)}',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: AppColor.abu,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Mulai ',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                ),
                              ),
                              Text(
                                'Rp ${formatAngka(w.harga)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.ungu,
                                ),
                              ),
                              Text(
                                ' /org',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: arahkan ke detail wisata
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.biru.withValues(alpha: 0.18),
                        foregroundColor: AppColor.ungu,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detail',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gambar(_Wisata w) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: ganti dengan Image.network(gambarDariBackend, fit: BoxFit.cover)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  w.warnaGambar.withValues(alpha: 0.6),
                  w.warnaGambar.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Icon(Icons.landscape_outlined,
                size: 48, color: AppColor.putih.withValues(alpha: 0.5)),
          ),

          // overlay gelap di bawah supaya teks rating terbaca
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColor.hitam.withValues(alpha: 0),
                    AppColor.hitam.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),

          // badge diskon + chip info
          Positioned(
            top: 10,
            left: 10,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: w.badgeWarna,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    w.badge,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: w.badgeTeks,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.putih.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(w.chipIcon, size: 11, color: AppColor.ungu),
                      const SizedBox(width: 3),
                      Text(
                        w.chipInfo,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // tombol love
          Positioned(
            top: 8,
            right: 10,
            child: GestureDetector(
              onTap: () {
                // TODO: panggil API hapus/tambah wishlist
                setState(() => w.favorit = !w.favorit);
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: w.favorit ? AppColor.kuning : AppColor.putih,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  size: 15,
                  color: w.favorit ? AppColor.putih : AppColor.abu,
                ),
              ),
            ),
          ),

          // rating + kategori
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 14, color: AppColor.kuning),
                const SizedBox(width: 3),
                Text(
                  w.rating,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.putih,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${w.ulasan})',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    color: AppColor.putih.withValues(alpha: 0.85),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColor.hitam.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    w.kategori,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColor.putih,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}