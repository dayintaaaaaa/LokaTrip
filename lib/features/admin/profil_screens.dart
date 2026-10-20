import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/session_manager.dart';
import '../../widgets/admin_bottom_navigator.dart';
import '../login_screens.dart';
import 'pengaturan_akun_admin_screens.dart';

class ProfilAdminScreens extends StatefulWidget {
  const ProfilAdminScreens({super.key});

  @override
  State<ProfilAdminScreens> createState() => _ProfilAdminScreensState();
}

class _ProfilAdminScreensState extends State<ProfilAdminScreens> {
  // ── data dummy (nanti ganti dari backend) ──
  final String _nama = 'Administrator';
  final String _email = 'admin@lokatrip.id';
  final int _auditBulanIni = 142;
  final String _slaCompliance = '99.8%';
  final String _tier = 'Tier 1';
  bool _notifEnabled = true;

  // ── aktivitas ──
  final List<_Aktivitas> _aktivitas = [
    _Aktivitas(
      icon: Icons.check_circle_outline,
      iconColor: Color(0xFF22C55E),
      iconBg: Color(0xFFDCFCE7),
      judul: 'Admin menyetujui mitra ',
      judulLink: 'CV Pesona Nusantara',
      waktu: '16 Sep 2026, 10:32',
      badge: 'IP 103.24.12.9',
      badgeColor: Color(0xFFE0E7FF),
      badgeTextColor: Color(0xFF525EA7),
    ),
    _Aktivitas(
      icon: Icons.assignment_turned_in_outlined,
      iconColor: Color(0xFF525EA7),
      iconBg: Color(0xFFEEF0FF),
      judul: 'Admin menerbitkan izin ',
      judulLink: 'IZ-2026-00128',
      waktu: '16 Sep 2026, 10:45',
      badge: '✓ Sukses',
      badgeColor: Color(0xFFDCFCE7),
      badgeTextColor: Color(0xFF16A34A),
    ),
    _Aktivitas(
      icon: Icons.block_outlined,
      iconColor: Color(0xFFEF4444),
      iconBg: Color(0xFFFFE4E6),
      judul: 'Admin menangguhkan mitra ',
      judulLink: 'PT Jelajah...',
      waktu: '15 Sep 2026, 15:20',
      badge: null,
      badgeColor: null,
      badgeTextColor: null,
      alasan: 'Alasan: Berkas Dishub Kadaluarsa',
    ),
  ];

  Future<void> _logout() async {
    await SessionManager.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreens()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 12),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildAktivitasSection(),
                    const SizedBox(height: 16),
                    _buildPreferensiSection(),
                    const SizedBox(height: 20),
                    _buildLogoutButton(),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Sesi saat ini diamankan dengan enkripsi TLS 1.3 LokaTrip Enterprise',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: AppColor.abu,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavigator(
        currentIndex: 4,
        onTap: (_) {},
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColor.latar,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Logo + label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/LokaTrip-logo-no-van.png',
                    height: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ADMIN',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColor.ungu,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Profil',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Bell dengan badge merah
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: AppColor.hitam,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Profile Card ─────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Avatar + Online badge
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.ungu.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColor.ungu.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 38,
                  color: AppColor.ungu,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.putih, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Nama
          Text(
            _nama,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColor.hitam,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            _email,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppColor.abu,
            ),
          ),

          const SizedBox(height: 10),

          // Online label + Platform Administrator chip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Online
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Platform Administrator chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.ungu,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 12,
                      color: AppColor.putih,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Platform Administrator',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColor.putih,
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

  // ─── Stats Row ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: _cardDecoration(),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _statItem('$_auditBulanIni', 'Audit Bulan Ini',
                AppColor.hitam, false),
            _verticalDivider(),
            _statItem(_slaCompliance, 'SLA Compliance',
                AppColor.hitam, false),
            _verticalDivider(),
            _statItem(_tier, 'Akses Penuh', AppColor.ungu, true),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
      String angka, String label, Color angkaColor, bool bold) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            angka,
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: angkaColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: AppColor.abu,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColor.abu.withValues(alpha: 0.2),
    );
  }

  // ─── Aktivitas Administrator ───────────────────────────────────────────────
  Widget _buildAktivitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text('🛡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              'Aktivitas Administrator',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColor.hitam,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColor.ungu,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: _cardDecoration(),
          child: Column(
            children: List.generate(_aktivitas.length, (i) {
              final a = _aktivitas[i];
              return Column(
                children: [
                  _aktivitasTile(a),
                  if (i < _aktivitas.length - 1)
                    Divider(
                      height: 1,
                      indent: 14,
                      endIndent: 14,
                      color: AppColor.abu.withValues(alpha: 0.2),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _aktivitasTile(_Aktivitas a) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bulat berwarna
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: a.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(a.icon, size: 18, color: a.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul + link berwarna
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColor.hitam,
                    ),
                    children: [
                      TextSpan(text: a.judul),
                      TextSpan(
                        text: a.judulLink,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Waktu + badge
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                            size: 10, color: AppColor.abu),
                        const SizedBox(width: 3),
                        Text(
                          a.waktu,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                      ],
                    ),
                    if (a.badge != null) ...[
                      const Text('·',
                          style: TextStyle(
                              color: AppColor.abu, fontSize: 10)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: a.badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.badge!,
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: a.badgeTextColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (a.alasan != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    a.alasan!,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Preferensi & Kontrol Sistem ─────────────────────────────────────────
  Widget _buildPreferensiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferensi & Kontrol Sistem',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColor.hitam,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _menuTile(
                icon: Icons.manage_accounts_outlined,
                judul: 'Pengaturan Akun',
                sub: 'Detail profil, email dinas, dan kredensial',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengaturanAkunAdminScreens(),
                    ),
                  );
                },
              ),
              _divider(),
              _menuTileWithToggle(
                icon: Icons.notifications_outlined,
                judul: 'Notifikasi',
                sub: 'Push alerts, eskalasi izin, dan broadcast tel',
                value: _notifEnabled,
                onChanged: (val) => setState(() => _notifEnabled = val),
              ),
              _divider(),
              _menuTileWithChip(
                icon: Icons.security_outlined,
                judul: 'Keamanan',
                sub: 'Two-Factor Authentication & active se',
                chipText: '2FA\nAktif',
                chipBg: const Color(0xFFDCFCE7),
                chipTextColor: const Color(0xFF16A34A),
                onTap: () {},
              ),
              _divider(),
              _menuTile(
                icon: Icons.help_outline_rounded,
                judul: 'Bantuan & SOP Regulasi',
                sub: 'Panduan verifikasi Dishub & manual book adn',
                onTap: () {},
              ),
              _divider(),
              _menuTile(
                icon: Icons.info_outline_rounded,
                judul: 'Tentang LokaTrip',
                sub: 'Versi 2.4.0 — Enterprise Admin Platform',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String judul,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _menuIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: AppColor.abu,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColor.abu),
          ],
        ),
      ),
    );
  }

  Widget _menuTileWithToggle({
    required IconData icon,
    required String judul,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _menuIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColor.abu,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColor.ungu,
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColor.abu),
        ],
      ),
    );
  }

  Widget _menuTileWithChip({
    required IconData icon,
    required String judul,
    required String sub,
    required String chipText,
    required Color chipBg,
    required Color chipTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _menuIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: AppColor.abu,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                chipText,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: chipTextColor,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: AppColor.abu),
          ],
        ),
      ),
    );
  }

  Widget _menuIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColor.ungu),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        indent: 14,
        endIndent: 14,
        color: AppColor.abu.withValues(alpha: 0.2),
      );

  // ─── Logout Button ────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.exit_to_app_rounded, size: 18),
        label: Text(
          'Keluar dari Akun',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFECEC),
          foregroundColor: const Color(0xFFEF4444),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ─── Shared decoration ────────────────────────────────────────────────────
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColor.putih,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColor.hitam.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

// ─── Model Aktivitas ──────────────────────────────────────────────────────────
class _Aktivitas {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String judul;
  final String judulLink;
  final String waktu;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final String? alasan;

  const _Aktivitas({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.judul,
    required this.judulLink,
    required this.waktu,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    this.alasan,
  });
}
