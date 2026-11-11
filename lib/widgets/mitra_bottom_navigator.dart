import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    const activeColor = Color(0xFF1748D1);
    const inactiveColor = Color(0xFF94A3B8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = index == currentIndex;
              final color = isActive ? activeColor : inactiveColor;

              return Expanded(
                child: InkWell(
                  splashColor: activeColor.withValues(alpha: 0.08),
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (onTap != null) {
                      onTap!(index);
                    } else {
                      if (index == currentIndex) return;
                      navigateTo(context, index);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 22,
                        color: color,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: color,
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

