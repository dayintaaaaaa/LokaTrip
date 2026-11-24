import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';
import 'gambar_placeholder.dart';

class PromoFlashCard extends StatelessWidget {
  final Color warnaGambar;
  final String badge; // "Diskon 45%"
  final String lokasi;
  final String judul;
  final String rating;
  final String ulasan;
  final String harga;
  final String hargaCoret;
  final int sisaTiket;
  final int persenTerjual; // 0 - 100
  final VoidCallback? onTap;

  const PromoFlashCard({
    super.key,
    required this.warnaGambar,
    required this.badge,
    required this.lokasi,
    required this.judul,
    required this.rating,
    required this.ulasan,
    required this.harga,
    required this.hargaCoret,
    required this.sisaTiket,
    required this.persenTerjual,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GambarPlaceholder(
            warna: warnaGambar,
            tinggi: 110,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColor.hitam.withValues(alpha: 0),
                          AppColor.hitam.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.kuning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColor.ungu,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 6,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColor.putih),
                      const SizedBox(width: 3),
                      Text(
                        lokasi,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColor.putih,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: AppColor.kuning),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($ulasan)',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      harga,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColor.ungu,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hargaCoret,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 12, color: AppColor.kuning),
                    const SizedBox(width: 3),
                    Text(
                      'Sisa $sisaTiket Tiket',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColor.kuning,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$persenTerjual% Terjual',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (persenTerjual / 100).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColor.kuning.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColor.kuning),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.ungu,
                      foregroundColor: AppColor.putih,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Beli Tiket Flash Sale',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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