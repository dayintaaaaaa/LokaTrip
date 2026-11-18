import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../widgets/hitung_mundur.dart';

class BannerPromo extends StatelessWidget {
  final String label;
  final String judul;
  final String kupon;
  final DateTime berakhirPada;
  final VoidCallback? onSnkTap;

  const BannerPromo({
    super.key,
    required this.label,
    required this.judul,
    required this.kupon,
    required this.berakhirPada,
    this.onSnkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColor.ungu, const Color(0xFF6A74BE)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // ikon tiket sebagai hiasan di kanan
            Positioned(
              right: -4,
              bottom: -4,
              child: Transform.rotate(
                angle: -0.3,
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 84,
                  color: AppColor.putih.withValues(alpha: 0.15),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // label kuning
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColor.kuning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 13,
                        color: Color(0xFF1A1A2E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // judul
                Text(
                  judul,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColor.putih,
                  ),
                ),
                const SizedBox(height: 10),

                // kupon
                Row(
                  children: [
                    Text(
                      'Pakai kupon:',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColor.putih,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.putih,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        kupon,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColor.ungu,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // timer + S&K
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 13, color: AppColor.putih),
                    const SizedBox(width: 4),
                    Text(
                      'Berakhir dlm ',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.putih,
                      ),
                    ),
                    HitungMundur(
                      berakhirPada: berakhirPada,
                      builder: (jam, menit, detik) => Text(
                        '$jam:$menit:$detik',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColor.putih,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onSnkTap,
                      child: Text(
                        'S&K',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColor.putih,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColor.putih,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}