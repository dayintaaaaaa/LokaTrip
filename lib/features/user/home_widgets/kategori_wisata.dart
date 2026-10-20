import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import 'section_title.dart';

class _Kategori {
  final String label;
  final IconData icon;
  const _Kategori(this.label, this.icon);
}

class KategoriWisata extends StatelessWidget {
  const KategoriWisata({super.key});

  static const _data = [
    _Kategori('Atraksi & Hiburan', Icons.attractions_outlined),
    _Kategori('Candi & Sejarah', Icons.temple_buddhist_outlined),
    _Kategori('Waterpark', Icons.pool_outlined),
    _Kategori('Tur & Open Trip', Icons.hiking),
    _Kategori('Playground', Icons.toys_outlined),
    _Kategori('Spa & Pijat', Icons.spa_outlined),
    _Kategori('Alam & Outdoor', Icons.landscape_outlined),
    _Kategori('Semua Kategori', Icons.grid_view_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(judul: 'Kategori Wisata'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (_, i) {
              final k = _data[i];
              return InkWell(
                onTap: () {
                  // nanti: buka halaman Wisata dengan filter kategori ini
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
                      k.label,
                      maxLines: 1,
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