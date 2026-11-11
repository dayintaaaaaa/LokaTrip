import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';
import '../../../widgets/tombol_kartu.dart';

// Kartu tur: label kuning, lokasi + jenis tur di gambar, chip fitur.
class KartuTur extends StatelessWidget {
  final Wisata wisata;
  final VoidCallback? onTap;

  const KartuTur({super.key, required this.wisata, this.onTap});

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

                  // rating + ulasan + keterangan
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
                      if (w.termasuk != null) ...[
                        Text(
                          '  •  ',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            w.termasuk!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColor.ungu,
                            ),
                          ),
                        ),
                      ],
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
                              Text(
                                formatRupiah(w.hargaAsli!),
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                  decoration: TextDecoration.lineThrough,
                                ),
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
                                      fontSize: 19,
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
                      TombolKartu(label: 'Pilih Paket'),
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

  // gambar + label atas + hati + lokasi + jenis tur
  Widget _gambar(Wisata w) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GambarWisata(path: w.gambar),

          // dua label kiri atas
          Positioned(
            top: 10,
            left: 10,
            right: 44,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (w.labelGambar != null) _labelKuning(w.labelGambar!),
                if (w.tipe != null) _labelBiru(w.tipe!),
              ],
            ),
          ),

          // hati: sama dengan halaman lain
          Positioned(top: 4, right: 6, child: TombolFavorit(wisataId: w.id)),

          // lokasi kiri bawah
          Positioned(
            left: 10,
            bottom: 10,
            right: w.subkategori == null ? 10 : 110,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _gelap.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 11, color: AppColor.putih),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        w.lokasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColor.putih,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // jenis tur kanan bawah
          if (w.subkategori != null)
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _gelap.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  w.subkategori!,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColor.putih,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _labelKuning(String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.kuning,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _gelap,
        ),
      ),
    );
  }

  Widget _labelBiru(String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEFFA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 11, color: AppColor.ungu),
          const SizedBox(width: 2),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColor.ungu,
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
        color: const Color(0xFFF1F3FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
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
              color: AppColor.hitam,
            ),
          ),
        ],
      ),
    );
  }

  // ikon dipilih dari kata kunci di teks fitur
  IconData _ikonFitur(String teks) {
    final k = teks.toLowerCase();
    if (k.contains('foto') || k.contains('video')) {
      return Icons.photo_camera_outlined;
    }
    if (k.contains('helm') || k.contains('safety')) {
      return Icons.shield_outlined;
    }
    if (k.contains('driver') || k.contains('guide') || k.contains('pilot')) {
      return Icons.person_outline;
    }
    if (k.contains('transport') || k.contains('shuttle')) {
      return Icons.directions_bus_outlined;
    }
    if (k.contains('makan') || k.contains('lunch') || k.contains('minuman')) {
      return Icons.restaurant_outlined;
    }
    if (k.contains('tiket')) return Icons.confirmation_number_outlined;
    return Icons.check_circle_outline;
  }
}