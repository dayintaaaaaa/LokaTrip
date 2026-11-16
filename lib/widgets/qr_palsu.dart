import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_color.dart';

class QrPalsu extends StatelessWidget {
  final String seed;
  final double ukuran;
  final Color warna;
  final bool logo;

  const QrPalsu({
    super.key,
    required this.seed,
    this.ukuran = 180,
    this.warna = AppColor.hitam,
    this.logo = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ukuran,
      height: ukuran,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(ukuran, ukuran),
            painter: _QrPainter(seed, warna),
          ),
          if (logo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColor.putih,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.hitam.withValues(alpha: 0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Text(
                'LT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColor.ungu,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final String seed;
  final Color warna;
  _QrPainter(this.seed, this.warna);

  static const int n = 25;

  bool _finder(int r, int c) =>
      (r < 8 && c < 8) || (r < 8 && c >= n - 8) || (r >= n - 8 && c < 8);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / n;
    final isi = Paint()..color = warna;
    final kosong = Paint()..color = AppColor.putih;
    final rnd = Random(seed.hashCode);

    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final acak = rnd.nextBool();
        if (_finder(r, c)) continue;
        if (r >= 10 && r <= 14 && c >= 10 && c <= 14) continue; // area logo
        if (acak) {
          canvas.drawRect(
            Rect.fromLTWH(c * cell, r * cell, cell, cell),
            isi,
          );
        }
      }
    }

    void finder(int r0, int c0) {
      canvas.drawRect(
          Rect.fromLTWH(c0 * cell, r0 * cell, 7 * cell, 7 * cell), isi);
      canvas.drawRect(
          Rect.fromLTWH((c0 + 1) * cell, (r0 + 1) * cell, 5 * cell, 5 * cell),
          kosong);
      canvas.drawRect(
          Rect.fromLTWH((c0 + 2) * cell, (r0 + 2) * cell, 3 * cell, 3 * cell),
          isi);
    }

    finder(0, 0);
    finder(0, n - 7);
    finder(n - 7, 0);
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) =>
      old.seed != seed || old.warna != warna;
}