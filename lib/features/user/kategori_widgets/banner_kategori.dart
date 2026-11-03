import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../models/promo_kategori.dart';

class BannerKategori extends StatelessWidget {
  final PromoKategori promo;

  const BannerKategori({super.key, required this.promo});

  static const _gelap = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final flash = promo.label.toUpperCase().contains('FLASH');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColor.ungu, const Color(0xFF6A74BE)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // label (+ periode di kanan kalau ada)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.kuning,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (flash) ...[
                            const Icon(Icons.bolt, size: 11, color: _gelap),
                            const SizedBox(width: 2),
                          ],
                          Text(
                            promo.label,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _gelap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (promo.periode != null) ...[
                      const Spacer(),
                      Text(
                        promo.periode!,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColor.putih,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                Text(
                  promo.judul,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColor.putih,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  promo.deskripsi,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColor.putih.withValues(alpha: 0.9),
                  ),
                ),

                // kode + salin (hanya kalau ada kode)
                if (promo.kode != null) ...[
                  const SizedBox(height: 10),
                  _barisKode(context, promo.kode!),
                ],
              ],
            ),
          ),

          // tombol kanan (hanya kalau ada)
          if (promo.tombol != null) ...[
            const SizedBox(width: 12),
            _tombol(context, promo.tombol!),
          ],
        ],
      ),
    );
  }

  Widget _barisKode(BuildContext context, String kode) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColor.kuning.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.kuning),
          ),
          child: Text(
            kode,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColor.kuning,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: kode));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kode $kode disalin'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 13, color: AppColor.putih),
              const SizedBox(width: 4),
              Text(
                'Salin Kode',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColor.putih,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tombol(BuildContext context, String teks) {
    return GestureDetector(
      onTap: () {
        // nanti: simpan klaim promo ke akun user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promo berhasil diklaim'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.putih,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          teks,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColor.ungu,
          ),
        ),
      ),
    );
  }
}