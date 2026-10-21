import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';

// Label gelap transparan di atas gambar: ★ 4.9 (12.8k)
class BadgeRating extends StatelessWidget {
  final double rating;
  final String? ulasan; // teks di dalam kurung, contoh: '12.8k'

  const BadgeRating({super.key, required this.rating, this.ulasan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 13, color: AppColor.kuning),
          const SizedBox(width: 3),
          Text(
            '$rating',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColor.putih,
            ),
          ),
          if (ulasan != null)
            Text(
              ' ($ulasan)',
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: AppColor.putih.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }
}