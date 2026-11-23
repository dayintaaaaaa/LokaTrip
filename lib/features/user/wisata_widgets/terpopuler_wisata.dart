import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/badge_rating.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';
import '../home_widgets/section_title.dart';
import '../../user/destinasi_populer_screens.dart';
import '../../user/detail_wisata_screens.dart'; // arahkan kursor ke DetailWisataScreens di _buka() lalu Quick Fix > Import.
// arahkan kursor ke DetailWisataScreens di _buka() lalu Quick Fix > Import.

class TerpopulerWisata extends StatelessWidget {
  final List<Wisata> daftar;

  const TerpopulerWisata({super.key, required this.daftar});

  // buka halaman Destination Detail (ketuk kartu atau tombol Pilih Paket)
  void _buka(BuildContext context, Wisata w) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailWisataScreens(wisata: w)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lebarKartu = (MediaQuery.of(context).size.width * 0.62)
        .clamp(220.0, 270.0)
        .toDouble();

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DestinasiPopulerScreens(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

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
            height: 270,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: daftar.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) => _kartu(ctx, daftar[i], lebarKartu),
            ),
          ),
      ],
    );
  }

  Widget _kartu(BuildContext context, Wisata w, double lebar) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _buka(context, w),
      child: Container(
        width: lebar,
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
              height: 105,
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
                            : ringkasAngka(w.jumlahUlasan!),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // lokasi
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColor.ungu,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            w.lokasi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              color: AppColor.abu,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // nama
                    Text(
                      w.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // tipe tiket
                    if (w.tipe != null)
                      Row(
                        children: [
                          _chip(Icons.check_circle, w.tipe!, AppColor.biru),
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
                              Text(
                                formatRupiah(w.harga),
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.ungu,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _tombolPilih(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan tombol "Pilih Paket". Ketukannya ditangani GestureDetector di
  // kartu, jadi tombol dan kartu sama-sama membuka halaman detail.
  Widget _tombolPilih() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: AppColor.ungu,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pilih Paket',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColor.putih,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right, size: 15, color: AppColor.putih),
        ],
      ),
    );
  }

  Widget _chip(IconData ikon, String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: warna.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 10, color: warna),
          const SizedBox(width: 3),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }
}