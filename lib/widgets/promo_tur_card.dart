import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';
import 'gambar_placeholder.dart';

class PromoTurCard extends StatelessWidget {
  final Color warnaGambar;
  final String badge; // "-25%" / "Hemat 75rb"
  final Color badgeWarna;
  final Color badgeTeks;
  final String kategori; // "OPEN TRIP TERLARIS"
  final String judul;
  final String deskripsi;
  final String hargaCoret;
  final String harga;
  final VoidCallback? onTap;

  const PromoTurCard({
    super.key,
    required this.warnaGambar,
    required this.badge,
    required this.badgeWarna,
    required this.badgeTeks,
    required this.kategori,
    required this.judul,
    required this.deskripsi,
    required this.hargaCoret,
    required this.harga,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 90,
              child: GambarPlaceholder(
                warna: warnaGambar,
                tinggi: 90,
                lebar: 80,
                iconSize: 26,
                child: Stack(
                  children: [
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeWarna,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.manrope(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: badgeTeks,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kategori,
                  style: GoogleFonts.manrope(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: AppColor.biru,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  deskripsi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    color: AppColor.abu,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hargaCoret,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              color: AppColor.abu,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            harga,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColor.ungu,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.ungu.withValues(alpha: 0.1),
                        foregroundColor: AppColor.ungu,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Pesan',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
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
}