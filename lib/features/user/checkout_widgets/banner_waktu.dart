import 'package:flutter/foundation.dart'; // <- baru, untuk ValueListenable
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

// Banner "Selesaikan dalam 14:58 | Pesanan Terkunci".
// Memakai ValueListenable supaya hanya banner ini yang di-rebuild tiap detik.
class BannerWaktu extends StatelessWidget {
  final ValueListenable<int> sisaDetik;

  const BannerWaktu({super.key, required this.sisaDetik});

  String _format(int detik) {
    final m = (detik ~/ 60).toString().padLeft(2, '0');
    final s = (detik % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: AppColor.biru),
          const SizedBox(width: 8),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: sisaDetik,
              builder: (_, detik, _) => Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Selesaikan dalam ',
                      style: GoogleFonts.manrope(
                        fontSize: 10.5,
                        color: AppColor.hitam.withValues(alpha: 0.7),
                      ),
                    ),
                    TextSpan(
                      text: _format(detik),
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColor.kuning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColor.putih,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Pesanan Terkunci',
              style: GoogleFonts.manrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColor.hitam,
              ),
            ),
          ),
        ],
      ),
    );
  }
}