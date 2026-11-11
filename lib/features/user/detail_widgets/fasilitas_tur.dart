import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

// Kartu "Fasilitas Tur": daftar yang termasuk dan tidak termasuk.
class FasilitasTur extends StatelessWidget {
  final List<String> termasuk;
  final List<String> tidakTermasuk;

  const FasilitasTur({
    super.key,
    required this.termasuk,
    required this.tidakTermasuk,
  });

  @override
  Widget build(BuildContext context) {
    if (termasuk.isEmpty && tidakTermasuk.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fasilitas Tur',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColor.hitam,
            ),
          ),
          if (termasuk.isNotEmpty) ...[
            const SizedBox(height: 12),
            _judul(
              Icons.check_circle_outline,
              'TERMASUK DALAM PAKET',
              AppColor.ungu,
            ),
            const SizedBox(height: 8),
            for (final t in termasuk)
              _baris(Icons.check, t, AppColor.biru, AppColor.hitam),
          ],
          if (tidakTermasuk.isNotEmpty) ...[
            const SizedBox(height: 8),
            _judul(Icons.cancel_outlined, 'TIDAK TERMASUK', AppColor.abu),
            const SizedBox(height: 8),
            for (final t in tidakTermasuk)
              _baris(Icons.close, t, AppColor.abu, AppColor.abu),
          ],
        ],
      ),
    );
  }

  Widget _judul(IconData ikon, String teks, Color warna) {
    return Row(
      children: [
        Icon(ikon, size: 13, color: warna),
        const SizedBox(width: 5),
        Text(
          teks,
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: warna,
          ),
        ),
      ],
    );
  }

  Widget _baris(IconData ikon, String teks, Color warnaIkon, Color warnaTeks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(ikon, size: 13, color: warnaIkon),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              teks,
              style: GoogleFonts.manrope(
                fontSize: 10.5,
                color: warnaTeks,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}