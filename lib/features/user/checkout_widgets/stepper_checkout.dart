import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

// Penanda langkah: (1) Data Pemesan ---- (2) Pembayaran
class StepperCheckout extends StatelessWidget {
  final int aktif; // 1 atau 2

  const StepperCheckout({super.key, this.aktif = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _langkah(1, 'Data Pemesan'),
        const SizedBox(width: 10),
        Expanded(child: _garis()),
        const SizedBox(width: 10),
        _langkah(2, 'Pembayaran'),
      ],
    );
  }

  Widget _langkah(int nomor, String teks) {
    final nyala = aktif >= nomor;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: nyala ? AppColor.ungu : AppColor.ungu.withValues(alpha: 0.1),
          ),
          child: Text(
            '$nomor',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: nyala ? AppColor.putih : AppColor.abu,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          teks,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: nyala ? FontWeight.w700 : FontWeight.w500,
            color: nyala ? AppColor.hitam : AppColor.abu,
          ),
        ),
      ],
    );
  }

  // garis penghubung: setengah terisi di langkah 1, penuh di langkah 2
  Widget _garis() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: aktif >= 2 ? 1 : 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.ungu,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}