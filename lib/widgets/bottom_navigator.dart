import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final IconData iconAktif;
  const _NavItem(this.label, this.icon, this.iconAktif);
}

class BottomNavigator extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigator({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem('Beranda', Icons.home_outlined, Icons.home_rounded),
    _NavItem('Wisata', Icons.explore_outlined, Icons.explore),
    _NavItem('Pesanan', Icons.receipt_long_outlined, Icons.receipt_long),
    _NavItem('Promo', Icons.local_offer_outlined, Icons.local_offer),
    _NavItem('Akun', Icons.person_outline, Icons.person),
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
            offset:  Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final aktif = i == currentIndex;
              final warna = aktif ? AppColor.ungu : AppColor.abu;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        aktif ? item.iconAktif : item.icon,
                        size: 22,
                        color: warna,
                      ),

                      SizedBox(height: 4),

                      Text(
                        item.label,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                          color: warna
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