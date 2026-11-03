import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/favorite_store.dart';
import '../../core/format.dart';
import '../../core/format_rupiah.dart' show ringkasAngka;
import '../../models/wisata.dart';
import '../../models/wisata_dummy.dart';
import '../../widgets/gambar_wisata.dart';
import '../../widgets/sub_app_bar.dart';
import '../../widgets/tombol_favorit.dart';

class WishlistScreens extends StatefulWidget {
  const WishlistScreens({super.key});

  @override
  State<WishlistScreens> createState() => _WishlistScreensState();
}

class _WishlistScreensState extends State<WishlistScreens> {
  // Daftar diambil sekali saat halaman dibuka: wisata yang sedang difavoritkan.
  // Kalau hati ditekan lagi di sini, kartunya tetap tampil (hati jadi putih)
  // sampai halaman ditutup, jadi masih bisa dibatalkan.
  late final List<Wisata> _daftar;

  @override
  void initState() {
    super.initState();
    final ids = Set<int>.from(FavoritStore.ids.value);
    _daftar = WisataDummy.semuaWisata.where((w) => ids.contains(w.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
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

                // jumlah ikut berubah saat hati ditekan
                ValueListenableBuilder<Set<int>>(
                  valueListenable: FavoritStore.ids,
                  builder: (context, ids, _) {
                    final tersimpan =
                        _daftar.where((w) => ids.contains(w.id)).length;
                    return Text(
                      '$tersimpan Wisata Tersimpan',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                if (_daftar.isEmpty) _kosong() else ..._daftar.map(_kartu),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kosong() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, size: 40, color: AppColor.abu),
          const SizedBox(height: 8),
          Text(
            'Belum ada wisata tersimpan',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColor.abu,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tekan ikon hati di kartu wisata untuk menyimpannya',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
          ),
        ],
      ),
    );
  }

  Widget _kartu(Wisata w) {
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
                  w.nama,
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
                    Expanded(
                      child: Text(
                        w.lokasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: AppColor.abu,
                        ),
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
                          if (w.hargaAsli != null)
                            Text(
                              'Rp ${formatAngka(w.hargaAsli!)}',
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
                              if (w.satuanHarga != null)
                                Text(
                                  ' ${w.satuanHarga}',
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

  IconData _ikonTipe(String tipe) {
    final t = tipe.toLowerCase();
    if (t.contains('qr')) return Icons.qr_code_2;
    if (t.contains('instan') || t.contains('instant')) return Icons.bolt;
    return Icons.check_circle_outline;
  }

  Widget _gambar(Wisata w) {
    // label kiri atas: diskon kalau ada, kalau tidak 'Popular Choice'
    // untuk rating tinggi
    String? teksBadge;
    Color warnaBadge = AppColor.kuning;
    Color warnaTeksBadge = AppColor.ungu;
    if (w.diskonPersen > 0) {
      teksBadge = 'Diskon ${w.diskonPersen}%';
    } else if ((w.rating ?? 0) >= 4.9) {
      teksBadge = 'Popular Choice';
      warnaBadge = AppColor.ungu;
      warnaTeksBadge = AppColor.putih;
    }

    final labelKategori = w.kategori ?? w.subkategori;

    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // gambar (placeholder sama dengan halaman lain)
          GambarWisata(path: w.gambar),

          // bayangan gelap di bawah supaya teks rating terbaca
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
                if (teksBadge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: warnaBadge,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      teksBadge,
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: warnaTeksBadge,
                      ),
                    ),
                  ),
                if (teksBadge != null && w.tipe != null)
                  const SizedBox(width: 6),
                if (w.tipe != null)
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
                        Icon(_ikonTipe(w.tipe!),
                            size: 11, color: AppColor.ungu),
                        const SizedBox(width: 3),
                        Text(
                          w.tipe!,
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

          // tombol love: sama dengan kartu di halaman Wisata
          Positioned(
            top: 4,
            right: 6,
            child: TombolFavorit(wisataId: w.id),
          ),

          // rating + kategori
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            child: Row(
              children: [
                if (w.rating != null) ...[
                  const Icon(Icons.star_rounded,
                      size: 14, color: AppColor.kuning),
                  const SizedBox(width: 3),
                  Text(
                    '${w.rating}',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColor.putih,
                    ),
                  ),
                  if (w.jumlahUlasan != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${ringkasAngka(w.jumlahUlasan!)} ulasan)',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.putih.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
                const Spacer(),
                if (labelKategori != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColor.hitam.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      labelKategori,
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