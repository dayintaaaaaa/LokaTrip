import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/detail_wisata.dart';

// Kartu satu opsi paket di halaman Destination Detail.
class KartuPaket extends StatelessWidget {
  final PaketTiket paket;
  final bool dipilih;
  final VoidCallback onPilih;

  const KartuPaket({
    super.key,
    required this.paket,
    required this.dipilih,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    final p = paket;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dipilih
              ? AppColor.ungu.withValues(alpha: 0.45)
              : AppColor.abu.withValues(alpha: 0.2),
        ),
        boxShadow: dipilih
            ? [
                BoxShadow(
                  color: AppColor.ungu.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label + durasi
          if (p.label != null || p.durasi != null) ...[
            Row(
              children: [
                if (p.label != null) _label(p.label!, p.populer),
                const Spacer(),
                if (p.durasi != null) ...[
                  Icon(Icons.schedule, size: 12, color: AppColor.abu),
                  const SizedBox(width: 4),
                  Text(
                    p.durasi!,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColor.abu,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],

          // nama paket
          Text(
            p.nama,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColor.hitam,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          // deskripsi
          Text(
            p.deskripsi,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: AppColor.abu,
              height: 1.45,
            ),
          ),

          // chip fitur
          if (p.fitur.isNotEmpty) ...[
            const SizedBox(height: 10),
            _kotakFitur(p.fitur),
          ],
          const SizedBox(height: 12),

          // harga + tombol
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _harga(p)),
              ElevatedButton(
                onPressed: onPilih,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dipilih
                      ? AppColor.ungu
                      : AppColor.ungu.withValues(alpha: 0.12),
                  foregroundColor: dipilih ? AppColor.putih : AppColor.ungu,
                  elevation: 0,
                  minimumSize: const Size(0, 38),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Pilih Paket',
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
    );
  }

  Widget _label(String teks, bool populer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: populer ? const Color(0xFFDCEFFA) : const Color(0xFFEEF0F8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (populer) ...[
            const Icon(Icons.star_rounded, size: 11, color: AppColor.ungu),
            const SizedBox(width: 3),
          ],
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: AppColor.ungu,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kotakFitur(List<String> fitur) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: [
          for (final f in fitur)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 12,
                  color: AppColor.ungu,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    f,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColor.hitam,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _harga(PaketTiket p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (p.hargaAsli != null)
          Text(
            formatRupiah(p.hargaAsli!),
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: AppColor.abu,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: formatRupiah(p.harga),
                style: GoogleFonts.outfit(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ungu,
                ),
              ),
              TextSpan(
                text: ' ${p.satuan}',
                style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
              ),
            ],
          ),
        ),
        if (p.hargaUsd != null)
          Text(
            p.hargaUsd!,
            style: GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
          ),
      ],
    );
  }
}