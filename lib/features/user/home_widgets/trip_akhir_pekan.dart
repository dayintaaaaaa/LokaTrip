import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/gambar_wisata.dart';
import 'section_title.dart';

class TripAkhirPekan extends StatelessWidget {
  final List<Wisata> daftar;

  const TripAkhirPekan({super.key, required this.daftar});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          judul: 'Trip Spesial Akhir Pekan',
          subjudul: 'Kurasi wisata anti-bosan buat Sabtu-Minggu ceria',
          warnaAksen: AppColor.kuning,
          teksAksi: 'Filter',
          ikonAksi: Icons.filter_list,
          onLihatSemua: () {
            // nanti: buka filter
          },
        ),
        const SizedBox(height: 14),

        // daftar kartu vertikal
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final w in daftar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _KartuTrip(wisata: w),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KartuTrip extends StatelessWidget {
  final Wisata wisata;

  const _KartuTrip({required this.wisata});

  @override
  Widget build(BuildContext context) {
    final w = wisata;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // gambar + label bawah
              SizedBox(
                width: 96,
                height: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GambarWisata(path: w.gambar),
                      if (w.labelGambar != null)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E)
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(6),
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
                ),
              ),
              const SizedBox(width: 12),

              // info kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // tipe + lokasi
                    Row(
                      children: [
                        if (w.tipe != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.biru.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              w.tipe!,
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColor.biru,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // rating + cuplikan ulasan
                    Row(
                      children: [
                        if (w.rating != null) ...[
                          Icon(Icons.star_rounded,
                              size: 13, color: AppColor.kuning),
                          const SizedBox(width: 2),
                          Text(
                            '${w.rating}',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColor.hitam,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (w.ulasan != null)
                          Expanded(
                            child: Text(
                              '"${w.ulasan}"',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: AppColor.abu,
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

          const SizedBox(height: 10),
          Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.25)),
          const SizedBox(height: 10),

          // termasuk + harga
          Row(
            children: [
              Expanded(
                child: w.termasuk != null
                    ? Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 15, color: AppColor.ungu),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              w.termasuk!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: AppColor.hitam,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  children: [
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
        ],
      ),
    );
  }
}