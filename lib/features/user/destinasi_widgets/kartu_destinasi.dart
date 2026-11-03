import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';

class KartuDestinasi extends StatelessWidget {
  final Wisata wisata;
  final VoidCallback? onTap;

  const KartuDestinasi({super.key, required this.wisata, this.onTap});

  static const _gelap = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final w = wisata;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.putih,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gambar(w),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // nama
                  Text(
                    w.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // rating + subkategori
                  Row(
                    children: [
                      if (w.rating != null) ...[
                        Icon(Icons.star_rounded,
                            size: 13, color: AppColor.kuning),
                        const SizedBox(width: 2),
                        Text(
                          '${w.rating}',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                      ],
                      if (w.jumlahUlasan != null)
                        Text(
                          ' (${ringkasAngka(w.jumlahUlasan!)} ulasan)',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                      if (w.subkategori != null)
                        Expanded(
                          child: Text(
                            '  •  ${w.subkategori}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: AppColor.abu,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // chip fitur
                  if (w.fitur.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final f in w.fitur) _chipFitur(f)],
                    ),
                  ],

                  // bonus
                  if (w.bonus != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.kuning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColor.kuning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.monetization_on_outlined,
                              size: 13, color: AppColor.kuning),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              w.bonus!,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8A5A00),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // harga + tombol
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (w.hargaAsli != null)
                              Row(
                                children: [
                                  Text(
                                    formatRupiah(w.hargaAsli!),
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: AppColor.abu,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.kuning
                                          .withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '-${w.diskonPersen}%',
                                      style: GoogleFonts.manrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF8A5A00),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Mulai dari',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                ),
                              ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: formatRupiah(w.harga),
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.ungu,
                                    ),
                                  ),
                                  if (w.satuanHarga != null)
                                    TextSpan(
                                      text: ' ${w.satuanHarga}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        color: AppColor.abu,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // nanti: pilih tiket / buka detail
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.ungu,
                          foregroundColor: AppColor.putih,
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pilih Tiket',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right, size: 16),
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
      ),
    );
  }

  // gambar + label peringkat + hati + lokasi
  Widget _gambar(Wisata w) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GambarWisata(path: w.gambar),

          // label peringkat (kiri atas)
          if (w.labelGambar != null)
            Positioned(top: 10, left: 10, child: _badgePeringkat(w.labelGambar!)),

          // hati: sama dengan halaman Wisata dan Wishlist
          Positioned(top: 4, right: 6, child: TombolFavorit(wisataId: w.id)),

          // lokasi (kiri bawah)
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _gelap.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 11, color: AppColor.putih),
                  const SizedBox(width: 3),
                  Text(
                    w.lokasi,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColor.putih,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgePeringkat(String teks) {
    final utama = teks.startsWith('#1');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: utama ? AppColor.kuning : AppColor.putih.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 11,
            color: utama ? _gelap : AppColor.ungu,
          ),
          const SizedBox(width: 3),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: utama ? _gelap : AppColor.ungu,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipFitur(String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.biru.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.biru.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_ikonFitur(teks), size: 11, color: AppColor.ungu),
          const SizedBox(width: 4),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColor.ungu,
            ),
          ),
        ],
      ),
    );
  }

  // ikon dipilih dari kata kunci di teks fitur
  IconData _ikonFitur(String teks) {
    final k = teks.toLowerCase();
    if (k.contains('reschedule')) return Icons.event_repeat;
    if (k.contains('asuransi')) return Icons.shield_outlined;
    if (k.contains('kids')) return Icons.child_care;
    if (k.contains('tiket') || k.contains('masuk') || k.contains('akses')) {
      return Icons.confirmation_number_outlined;
    }
    return Icons.check_circle_outline;
  }
}