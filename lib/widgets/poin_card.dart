import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';
import '../core/format.dart';

class PoinCard extends StatelessWidget {
  final int saldo;
  final String tier;
  final String? subtitle; // contoh: "Setara nilai hemat hingga Rp 245.000"
  final String progressKiri;
  final String progressKanan;
  final double progress; // 0.0 - 1.0
  final String footerKiri;
  final String? footerKanan;
  final VoidCallback? onTukar;
  final VoidCallback? onRiwayat;

  const PoinCard({
    super.key,
    required this.saldo,
    required this.tier,
    this.subtitle,
    required this.progressKiri,
    required this.progressKanan,
    required this.progress,
    required this.footerKiri,
    this.footerKanan,
    this.onTukar,
    this.onRiwayat,
  });

  @override
  Widget build(BuildContext context) {
    final putihSamar = AppColor.putih.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.ungu, AppColor.ungu.withValues(alpha: 0.85)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.ungu.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label + tier
          Row(
            children: [
              Text(
                'SALDO LOKA-POIN',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: putihSamar,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 12, color: putihSamar),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.kuning,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tier,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColor.ungu,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // saldo
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.monetization_on_rounded,
                  color: AppColor.kuning, size: 28),
              const SizedBox(width: 8),
              Text(
                formatAngka(saldo),
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColor.putih,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'Poin',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.putih,
                  ),
                ),
              ),
            ],
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.trending_up,
                    size: 12, color: AppColor.kuning),
                const SizedBox(width: 4),
                Text(
                  subtitle!,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kuning,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.putih.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressKiri,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColor.putih,
                      ),
                    ),
                    Text(
                      progressKanan,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColor.kuning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColor.putih.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColor.kuning),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        footerKiri,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: putihSamar,
                        ),
                      ),
                    ),
                    if (footerKanan != null)
                      Text(
                        footerKanan!,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: putihSamar,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // tombol (opsional, dipakai di halaman Akun)
          if (onTukar != null || onRiwayat != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTukar,
                    icon: const Icon(Icons.card_giftcard, size: 16),
                    label: Text(
                      'Tukar Poin',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.putih,
                      foregroundColor: AppColor.ungu,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRiwayat,
                    icon: const Icon(Icons.history, size: 16),
                    label: Text(
                      'Riwayat Poin',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.putih.withValues(alpha: 0.18),
                      foregroundColor: AppColor.putih,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}