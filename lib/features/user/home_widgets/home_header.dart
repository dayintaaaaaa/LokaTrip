import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

class _ChipData {
  final IconData icon;
  final String label;
  final String query;
  const _ChipData(this.icon, this.label, this.query);
}

class HomeHeader extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onFilter;

  const HomeHeader({super.key, required this.onSearch, required this.onFilter});

  // isi chip cepat
  static const _chips = [
    _ChipData(Icons.trending_up, 'Trending Labuan Bajo', 'Labuan Bajo'),
    _ChipData(Icons.bolt, 'Tiket Dufan Ancol', 'Dufan Ancol'),
    _ChipData(
      Icons.verified_outlined,
      'Borobudur Sunrise',
      'Borobudur Sunrise',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColor.ungu, AppColor.biru, AppColor.putih],
          stops: [0.0, 0.8, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // sapaan
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo Traveler!',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColor.putih,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Mau eksplor liburan seru ke mana hari ini?',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColor.putih,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // kolom pencarian sama filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              padding: EdgeInsets.only(left: 14, right: 6),
              decoration: BoxDecoration(
                color: AppColor.putih,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.hitam.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 20, color: AppColor.abu),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.manrope(fontSize: 12),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (kata) => onSearch(kata.trim()),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Cari tiket wisata, wahana, open trip..',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColor.abu,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onFilter,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColor.biru.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.tune, size: 18, color: AppColor.biru),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 14),

          // chip (geser ke samping)
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = _chips[i];
                return GestureDetector(
                  onTap: () => onSearch(c.query),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColor.putih.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 14, color: AppColor.putih),
                        const SizedBox(width: 6),
                        Text(
                          c.label,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColor.putih,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }
}
