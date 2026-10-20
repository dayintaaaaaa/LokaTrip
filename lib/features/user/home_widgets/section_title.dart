import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

class SectionTitle extends StatelessWidget {
  final String judul;
  final String? subjudul;
  final Color? warnaAksen; // warna garis di kiri judul (default ungu)
  final Widget? aksesori; // widget di samping judul (contoh: timer)
  final VoidCallback? onLihatSemua; // null = tombol disembunyikan

  const SectionTitle({
    super.key,
    required this.judul,
    this.subjudul,
    this.warnaAksen,
    this.aksesori,
    this.onLihatSemua,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // garis aksen di kiri judul
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: warnaAksen ?? AppColor.ungu,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),

              // judul + aksesori
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        judul,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.hitam,
                        ),
                      ),
                    ),
                    if (aksesori != null) ...[
                      const SizedBox(width: 8),
                      aksesori!,
                    ],
                  ],
                ),
              ),

              if (onLihatSemua != null)
                GestureDetector(
                  onTap: onLihatSemua,
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColor.biru,
                    ),
                  ),
                ),
            ],
          ),
          if (subjudul != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                subjudul!,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: AppColor.abu,
                ),
              ),
            ),
        ],
      ),
    );
  }
}