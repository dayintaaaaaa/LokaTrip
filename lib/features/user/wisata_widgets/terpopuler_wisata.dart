import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/badge_rating.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';
import '../home_widgets/section_title.dart';

class TerpopulerWisata extends StatelessWidget {
  final List<Wisata> daftar;

  const TerpopulerWisata({super.key, required this.daftar});

  static const _amber = AppColor.kuning;

  @override
  Widget build(BuildContext context) {
    final lebarKartu =
        (MediaQuery.of(context).size.width * 0.75).clamp(240.0, 320.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          judul: 'Destinasi Terpopuler',
          subjudul: 'Tiket atraksi favorit paling laris',
          warnaAksen: AppColor.ungu,
          ikonAksi: Icons.chevron_right,
          ikonDiAkhir: true,
          onLihatSemua: () {
            // nanti: buka daftar lengkap
          },
        ),
        const SizedBox(height: 14),

        if (daftar.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Belum ada destinasi di lokasi ini',
              style: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
            ),
          )
        else
          SizedBox(
            height: 340,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: daftar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _kartu(daftar[i], lebarKartu),
            ),
          ),
      ],
    );
  }

  Widget _kartu(Wisata w, double lebar) {
    return Container(
      width: lebar,
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
            height: 150,
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
                          : ringkasAngka(w.jumlahUlasan!),
                    ),
                  ),
                const Positioned(top: 8, right: 8, child: TombolFavorit()),
              ],
            ),
          ),

          // isi kartu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // lokasi
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: AppColor.ungu),
                      const SizedBox(width: 4),
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
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // chip tipe + poin
                  if (w.tipe != null || w.poin != null)
                    Row(
                      children: [
                        if (w.tipe != null)
                          _chip(Icons.check_circle, w.tipe!, AppColor.biru),
                        if (w.tipe != null && w.poin != null)
                          const SizedBox(width: 6),
                        if (w.poin != null)
                          _chip(
                            Icons.monetization_on_outlined,
                            '+${w.poin} Poin',
                            _amber,
                          ),
                      ],
                    ),

                  const Spacer(),

                  // harga + tombol
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                            Text(
                              formatRupiah(w.harga),
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColor.ungu,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // nanti: beli tiket / buka detail
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
                          'Beli Tiket',
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
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData ikon, String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: warna.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 11, color: warna),
          const SizedBox(width: 4),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }
}