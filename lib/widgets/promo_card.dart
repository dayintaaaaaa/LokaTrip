import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';
import 'gambar_placeholder.dart';

class PromoFitur {
  final IconData icon;
  final String teks;
  const PromoFitur(this.icon, this.teks);
}

class PromoCard extends StatelessWidget {
  final Color warnaGambar;
  final String badgeUtama; // "Diskon 35%"
  final String badgeKedua; // "Hemat Rp 45.000"
  final String lokasi;
  final String kategoriLokasi;
  final String judul;
  final String rating;
  final String ulasan;
  final String chipInfo;
  final List<PromoFitur> fitur;
  final String labelHarga; // "Mulai dari" / "Harga Promo Bundling"
  final String hargaCoret; // "Rp 125.000"
  final String harga; // "Rp 80.000"
  final String satuan; // "/orang"
  final String teksTombol;
  final VoidCallback? onTap;

  const PromoCard({
    super.key,
    required this.warnaGambar,
    required this.badgeUtama,
    required this.badgeKedua,
    required this.lokasi,
    required this.kategoriLokasi,
    required this.judul,
    required this.rating,
    required this.ulasan,
    required this.chipInfo,
    required this.fitur,
    required this.labelHarga,
    required this.hargaCoret,
    required this.harga,
    required this.satuan,
    required this.teksTombol,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final biruMuda = Color.alphaBlend(
      AppColor.biru.withValues(alpha: 0.3),
      AppColor.putih,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== gambar =====
          SizedBox(
            height: 150,
            child: GambarPlaceholder(
              warna: warnaGambar,
              tinggi: 150,
              child: Stack(
                children: [
                  // gelap di bawah supaya teks lokasi terbaca
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColor.hitam.withValues(alpha: 0),
                            AppColor.hitam.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      children: [
                        _badge(badgeUtama, AppColor.kuning, AppColor.ungu),
                        const SizedBox(width: 6),
                        _badge(badgeKedua, biruMuda, AppColor.ungu),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 8,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColor.putih),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '$lokasi  •  $kategoriLokasi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColor.putih,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== isi =====
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColor.kuning),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($ulasan)',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColor.biru.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        chipInfo,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: fitur.map(_chipFitur).toList(),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.2)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labelHarga,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: AppColor.abu,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                hargaCoret,
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                harga,
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.ungu,
                                ),
                              ),
                              Text(
                                ' $satuan',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.ungu,
                        foregroundColor: AppColor.putih,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            teksTombol,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String teks, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  Widget _chipFitur(PromoFitur f) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.latar,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(f.icon, size: 12, color: AppColor.ungu),
          const SizedBox(width: 4),
          Text(
            f.teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColor.hitam.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}