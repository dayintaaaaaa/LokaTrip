import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';
import '../features/user/home_screens.dart';
import '../features/user/wisata_screens.dart';
import '../features/user/pesanan_screens.dart';
import '../features/user/promo_screens.dart';
import '../features/user/akun_screens.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final IconData iconAktif;
  const _NavItem(this.label, this.icon, this.iconAktif);
}

class BottomNavigator extends StatelessWidget {
  final int currentIndex;

  const BottomNavigator({
    super.key,
    required this.currentIndex,
  });

  static const _items = [
    _NavItem('Beranda', Icons.home_outlined, Icons.home_rounded),
    _NavItem('Wisata', Icons.explore_outlined, Icons.explore),
    _NavItem('Pesanan', Icons.receipt_long_outlined, Icons.receipt_long),
    _NavItem('Promo', Icons.local_offer_outlined, Icons.local_offer),
    _NavItem('Akun', Icons.person_outline, Icons.person),
  ];

  void _pindah(BuildContext context, int index) {
    if (index == currentIndex) return; // sudah di halaman ini

    final Widget tujuan = switch (index) {
      0 => const HomeScreens(),
      1 => const WisataScreens(),
      2 => const PesananScreens(),
      3 => const PromoScreens(),
      _ => const AkunScreens(),
    };

    // pindah tanpa animasi supaya terasa seperti ganti tab
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => tujuan,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

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
                  onTap: () => _pindah(context, i),
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