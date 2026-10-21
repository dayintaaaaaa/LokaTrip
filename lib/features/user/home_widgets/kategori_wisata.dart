import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../models/kategori.dart';
import 'section_title.dart';

class KategoriWisata extends StatelessWidget {
  final bool tampilJudul;
  final int maxBaris; // jumlah baris maksimal label kategori

  const KategoriWisata({
    super.key,
    this.tampilJudul = true,
    this.maxBaris = 1,
  });

  // 7 kategori + tile "Semua Kategori" di akhir
  static const _data = [...Kategori.daftar, Kategori.semua];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tampilJudul) ...[
          const SectionTitle(judul: 'Kategori Wisata'),
          const SizedBox(height: 16),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              // label 2 baris: tinggi sel dikunci, 1 baris: pakai rasio lama
              mainAxisExtent: maxBaris == 1 ? null : 92,
            ),
            itemBuilder: (_, i) {
              final k = _data[i];
              return InkWell(
                onTap: () {
                  // nanti: buka halaman wisata untuk kategori ini
                },
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColor.ungu.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(k.icon, size: 26, color: AppColor.ungu),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      k.nama,
                      maxLines: maxBaris,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColor.hitam,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}