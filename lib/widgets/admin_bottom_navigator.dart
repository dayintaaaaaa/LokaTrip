import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';

class AdminBottomNavigator extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;

  const AdminBottomNavigator({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const _labels = [
    'Dashboard',
    'Mitra',
    'Perizinan',
    'Laporan',
    'Profil',
  ];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.storefront_outlined,
    Icons.assignment_outlined,
    Icons.bar_chart_outlined,
    Icons.person_outline,
  ];

  static const _iconsAktif = [
    Icons.dashboard_rounded,
    Icons.storefront_rounded,
    Icons.assignment_rounded,
    Icons.bar_chart_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.putih,
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_labels.length, (i) {
              final aktif = i == currentIndex;
              final warna = aktif ? AppColor.ungu : AppColor.abu;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap?.call(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // badge khusus Perizinan (index 2)
                      if (i == 2)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              aktif ? _iconsAktif[i] : _icons[i],
                              size: 22,
                              color: warna,
                            ),
                            Positioned(
                              top: -4,
                              right: -6,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '3',
                                    style: GoogleFonts.manrope(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: AppColor.putih,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Icon(
                          aktif ? _iconsAktif[i] : _icons[i],
                          size: 22,
                          color: warna,
                        ),

                      const SizedBox(height: 4),

                      Text(
                        _labels[i],
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight:
                              aktif ? FontWeight.w700 : FontWeight.w500,
                          color: warna,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
