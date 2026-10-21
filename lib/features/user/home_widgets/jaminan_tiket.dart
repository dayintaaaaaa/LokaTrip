import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

class JaminanTiket extends StatelessWidget {
  const JaminanTiket({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.ungu.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // judul + keterangan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined,
                    size: 22, color: AppColor.ungu),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jaminan Tiket Resmi Lokatrip',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColor.hitam,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Garansi 100% uang kembali jika voucher terkendala di lokasi wisata.',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: AppColor.abu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // dua poin keunggulan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _poin(
                  Icons.sentiment_satisfied_alt_outlined,
                  '5 Juta+',
                  'Traveler Puas',
                ),
                _poin(
                  Icons.lock_outline,
                  'Aman',
                  'Pembayaran Instan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _poin(IconData ikon, String judul, String keterangan) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColor.putih,
            shape: BoxShape.circle,
          ),
          child: Icon(ikon, size: 18, color: AppColor.ungu),
        ),
        const SizedBox(height: 6),
        Text(
          judul,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColor.hitam,
          ),
        ),
        Text(
          keterangan,
          style: GoogleFonts.manrope(
            fontSize: 10,
            color: AppColor.abu,
          ),
        ),
      ],
    );
  }
}