import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../models/detail_wisata.dart';

// Bagian "Ulasan Pengunjung" di halaman Destination Detail.
class UlasanPengunjung extends StatelessWidget {
  final List<UlasanDetail> daftar;

  const UlasanPengunjung({super.key, required this.daftar});

  @override
  Widget build(BuildContext context) {
    if (daftar.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ulasan Pengunjung',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cerita nyata dari pelancong terverifikasi',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: AppColor.abu,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // nanti: buka halaman semua ulasan
              },
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ungu,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final u in daftar)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _kartu(u),
          ),
      ],
    );
  }

  Widget _kartu(UlasanDetail u) {
    final inisial = u.nama.isEmpty ? '?' : u.nama[0].toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColor.ungu.withValues(alpha: 0.12),
                child: Text(
                  inisial,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.ungu,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.nama,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    Text(
                      '${u.asal}  •  ${u.waktu}',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.star_rounded, size: 14, color: AppColor.kuning),
              const SizedBox(width: 2),
              Text(
                '${u.rating}',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '“${u.teks}”',
            style: GoogleFonts.manrope(
              fontSize: 10.5,
              color: AppColor.hitam.withValues(alpha: 0.8),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}