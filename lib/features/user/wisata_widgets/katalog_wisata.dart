import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/badge_rating.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';
import '../home_widgets/section_title.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              jumlahTiket,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColor.ungu,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

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
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _kartu(w),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _kartu(Wisata w) {
    return GestureDetector(
      onTap: () {
        // nanti: buka halaman Detail Wisata
      },
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
            // gambar + rating + hati
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GambarWisata(path: w.gambar),
                  if (w.rating != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: BadgeRating(
                        rating: w.rating!,
                        ulasan: w.jumlahUlasan == null
                            ? null
                            : '${ringkasAngka(w.jumlahUlasan!)} ulasan',
                      ),
                    ),
                  const Positioned(top: 8, right: 8, child: TombolFavorit()),
                ],
              ),
            ),

            // isi kartu
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColor.ungu,
                          ),
                        ),
                        if (w.subkategori != null)
                          TextSpan(
                            text: '  •  ${w.subkategori}',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: AppColor.abu,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // nama
                  Text(
                    w.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: AppColor.abu.withValues(alpha: 0.25),
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
                              Text(
                                formatRupiah(w.hargaAsli!),
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
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
                                      fontSize: 11,
                                      color: AppColor.abu,
                                    ),
                                  ),
                                  TextSpan(
                                    text: formatRupiah(w.harga),
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.ungu,
                                    ),
                                  ),
                                  if (w.satuanHarga != null)
                                    TextSpan(
                                      text: ' ${w.satuanHarga}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 11,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Pilih Tiket',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
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
}