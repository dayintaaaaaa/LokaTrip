import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/mitra_theme.dart';

import '../features/admin_mitra/legalitas_mitra_screen.dart';
import '../features/admin_mitra/pengajuan_mitra_screens.dart';
import '../features/admin_mitra/profil_mitra_screen.dart';
import '../features/admin_mitra/wisata_saya_mitra_screen.dart';

class MitraBottomNavigator extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;

  const MitraBottomNavigator({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const _navItems = [
    _MitraNavItem(
      label: 'Pengajuan',
      icon: Icons.fact_check_outlined,
      activeIcon: Icons.fact_check_rounded,
    ),
    _MitraNavItem(
      label: 'Wisata Saya',
      icon: Icons.filter_hdr_outlined,
      activeIcon: Icons.filter_hdr_rounded,
    ),
    _MitraNavItem(
      label: 'Legalitas',
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield_rounded,
    ),
    _MitraNavItem(
      label: 'Akun Mitra',
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts_rounded,
    ),
  ];

  static void navigateTo(BuildContext context, int targetIndex) {
    final Widget destination = switch (targetIndex) {
      0 => const PengajuanMitraScreens(),
      1 => const WisataSayaMitraScreen(),
      2 => const LegalitasMitraScreen(),
      3 => const ProfilMitraScreen(),
      _ => const WisataSayaMitraScreen(),
    };

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => destination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = MitraPalette.primary;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: MitraPalette.line)),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 68,
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: MitraPalette.primaryLight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: 21,
                color: selected ? activeColor : const Color(0xFF8792A5),
              );
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return GoogleFonts.manrope(
                fontSize: 10,
                height: 1.2,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? activeColor : const Color(0xFF8792A5),
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              if (onTap != null) {
                onTap!(index);
              } else if (index != currentIndex) {
                navigateTo(context, index);
              }
            },
            destinations: [
              for (final item in _navItems)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: item.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MitraNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _MitraNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
