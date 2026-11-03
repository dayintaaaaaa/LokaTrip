import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';

// Kartu dengan lokasi di bawah gambar dan label di kiri bawah gambar.
class KartuAtraksi extends StatelessWidget {
  final Wisata wisata;
  final VoidCallback? onTap;

  const KartuAtraksi({super.key, required this.wisata, this.onTap});

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
                  // lokasi
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: AppColor.ungu),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          w.lokasi,
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
                  const SizedBox(height: 6),

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
                              fontWeight: FontWeight.w600,
                              color: AppColor.ungu,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.biru
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${w.diskonPersen}%',
                                      style: GoogleFonts.manrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColor.ungu,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    formatRupiah(w.hargaAsli!),
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: AppColor.abu,
                                      decoration: TextDecoration.lineThrough,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Pilih Tiket',
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
            ),
          ],
        ),
      ),
    );
  }

  // gambar + label atas + hati + label bawah
  Widget _gambar(Wisata w) {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GambarWisata(path: w.gambar),

          // label putih kiri atas
          if (w.tipe != null)
            Positioned(
              top: 10,
              left: 10,
              right: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.putih.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_ikonLabel(w.tipe!), size: 11, color: AppColor.ungu),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          w.tipe!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColor.ungu,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // hati: sama dengan halaman lain
          Positioned(top: 4, right: 6, child: TombolFavorit(wisataId: w.id)),

          // label ungu kiri bawah
          if (w.labelGambar != null)
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.ungu.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  w.labelGambar!,
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

  // ikon dipilih dari kata kunci di teks label
  IconData _ikonLabel(String teks) {
    final k = teks.toLowerCase();
    if (k.contains('instant')) return Icons.bolt;
    if (k.contains('scan')) return Icons.qr_code_scanner;
    if (k.contains('favorit')) return Icons.star_rounded;
    if (k.contains('wahana')) return Icons.attractions_outlined;
    return Icons.verified_outlined;
  }
}