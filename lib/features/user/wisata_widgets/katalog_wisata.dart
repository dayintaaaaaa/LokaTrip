import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/badge_rating.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';
import '../home_widgets/section_title.dart';
import '../../../widgets/tombol_kartu.dart';
import '../../../core/navigasi_wisata.dart';

class KatalogWisata extends StatelessWidget {
  final List<Wisata> daftar;
  final String jumlahTiket; // teks chip di kanan judul

  const KatalogWisata({
    super.key,
    required this.daftar,
    this.jumlahTiket = '350+ Tiket',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          judul: 'Katalog Wisata Pilihan',
          subjudul: 'Jelajahi tiket tanpa batas di seluruh nusantara',
          warnaAksen: AppColor.ungu,
          kanan: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              jumlahTiket,
              style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColor.ungu,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (daftar.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Belum ada wisata di lokasi ini',
              style: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final w in daftar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _kartu(context, w),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _kartu(BuildContext context, Wisata w) {
    return GestureDetector(
      onTap: () => bukaDetailWisata(context, w), 
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.putih,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // gambar + rating + hati
            SizedBox(
              height: 115,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GambarWisata(path: w.gambar),
                  if (w.rating != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: BadgeRating(
                        rating: w.rating!,
                        ulasan: w.jumlahUlasan == null
                            ? null
                            : '${ringkasAngka(w.jumlahUlasan!)} ulasan',
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 6,
                    child: TombolFavorit(wisataId: w.id),
                  ),
                ],
              ),
            ),

            // isi kartu
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // lokasi + subkategori
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: w.lokasi,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColor.ungu,
                          ),
                        ),
                        if (w.subkategori != null)
                          TextSpan(
                            text: '  •  ${w.subkategori}',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: AppColor.abu,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // nama
                  Text(
                    w.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 10),

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
                              ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Mulai dari ',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: AppColor.abu,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatRupiah(w.harga),
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
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
                      TombolKartu(
                        label: 'Pilih Paket',
                        onPressed: () => bukaDetailWisata(context, w),
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
}
