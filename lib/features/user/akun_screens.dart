
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api_client.dart';
import '../../core/app_color.dart';
import '../../core/favorite_store.dart';
import '../../core/session_manager.dart';
import '../../models/pesanan_saya.dart';
import '../../services/pesanan_service.dart';
import '../../services/profile_service.dart';
import '../../services/profile_store.dart';
import '../../widgets/top_navigator.dart';
import '../../widgets/bottom_navigator.dart';
import '../login_screens.dart';
import 'edit_profile_screens.dart';
import 'pesanan_screens.dart';
import 'wishlist_screens.dart';
import 'keamanan_akun_screens.dart';
import 'snk_screens.dart';

class AkunScreens extends StatefulWidget {
  const AkunScreens({super.key});

  @override
  State<AkunScreens> createState() => _AkunScreensState();
}

class _AkunScreensState extends State<AkunScreens> {
  int _jumlahUlasan = 0;
  int _jumlahWishlist = 0;

  // Jumlah e-tiket dari pesanan yang masih aktif.
  int _eTiketAktif = 0;

  // Email diambil dari akun login Supabase Auth.
  String get _email =>
      Supabase.instance.client.auth.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    _muatRingkasan();
    _muatETiket();
  }

  // Memuat jumlah ulasan dan wishlist dari API.
  Future<void> _muatRingkasan() async {
    try {
      final token = await SessionManager.currentUserToken();

      if (token == null || token.isEmpty) return;

      final result = await UserApi.summary(token);

      if (!mounted) return;

      setState(() {
        _jumlahWishlist =
            (result['wishlist_count'] as num?)?.toInt() ?? 0;

        _jumlahUlasan =
            (result['reviews_count'] as num?)?.toInt() ?? 0;
      });
    } catch (e) {
      debugPrint('Gagal memuat ringkasan akun: $e');
    }
  }

  // Memuat jumlah e-tiket dari pesanan aktif.
  Future<void> _muatETiket() async {
    try {
      final daftar = await PesananService().daftarSaya();

      final n = daftar
          .where((p) => p.status == StatusPesananSaya.aktif)
          .fold<int>(0, (a, p) => a + p.kodeTiket.length);

      if (!mounted) return;

      setState(() {
        _eTiketAktif = n;
      });
    } catch (e) {
      debugPrint('Gagal menghitung e-tiket aktif: $e');
    }
  }

  // Konfirmasi logout sebelum mengakhiri sesi.
  Future<void> _logout() async {
    final profil = ProfilStore.instance.profil.value;
    final nama = (profil?['nama_lengkap_user'] as String?)?.trim();
    final email = _email.trim();
    final telepon = ProfilStore.instance.telepon;
    final kontak = email.isNotEmpty ? email : telepon;
    final foto = ProfilStore.instance.fotoUrl;

    final konfirmasi = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup konfirmasi keluar',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, _, _) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.52)),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.88,
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  decoration: const BoxDecoration(
                    color: AppColor.putih,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6DEE9),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7E8),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFF3F0),
                                  width: 10,
                                ),
                              ),
                              child: const Icon(Icons.logout_rounded,
                                  size: 48, color: AppColor.kuning),
                            ),
                            Positioned(
                              right: -2,
                              bottom: 0,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColor.putih,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE5EAF1)),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x18000000), blurRadius: 6),
                                  ],
                                ),
                                child: const Icon(Icons.lock_outline_rounded,
                                    size: 21, color: Color(0xFF334155)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Keluar dari Akun?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text.rich(
                          TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 14, height: 1.55,
                              color: const Color(0xFF64748B),
                            ),
                            children: [
                              const TextSpan(
                                text: 'Sesi Anda akan berakhir. Tiket aktif dan riwayat perjalanan tetap tersimpan aman di akun Anda.',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFFE7EEF9),
                                backgroundImage: foto == null || foto.isEmpty
                                    ? null : NetworkImage(foto),
                                child: foto == null || foto.isEmpty
                                    ? const Icon(Icons.person_rounded,
                                        color: AppColor.ungu, size: 28)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama == null || nama.isEmpty
                                          ? 'Pengguna LokaTrip' : nama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      kontak.isEmpty ? 'Akun LokaTrip' : kontak,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.check_circle, size: 17,
                                    color: Color(0xFF2563EB)),
                                const SizedBox(width: 4),
                                Text('Tersimpan', style: GoogleFonts.manrope(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2563EB))),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.info_outline_rounded,
                                  size: 18, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Masuk kembali kapan saja dengan email atau nomor telepon yang terdaftar.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(
                                  fontSize: 12, height: 1.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity, height: 58,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            icon: const Icon(Icons.logout_rounded, size: 20),
                            label: const Text('Ya, Keluar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.kuning,
                              foregroundColor: AppColor.putih,
                              elevation: 0,
                              textStyle: GoogleFonts.manrope(
                                fontSize: 16, fontWeight: FontWeight.w800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity, height: 56,
                          child: TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF334155),
                              textStyle: GoogleFonts.manrope(
                                fontSize: 15, fontWeight: FontWeight.w800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: const Text('Batal & Tetap Masuk'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: 120, height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(5)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
    );

    if (konfirmasi != true || !mounted) return;
    final token = await SessionManager.currentUserToken();
    if (token != null && token.isNotEmpty) {
      try {
        await UserApi.logout(token);
      } catch (_) {
        try {
          await Supabase.instance.client.auth.signOut();
        } catch (_) {
          // Hapus sesi lokal meski server tidak dapat dihubungi.
        }
      }
    }
    await SessionManager.logout();
    ProfilStore.instance.bersihkan();
    FavoritStore.bersihkan();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreens(),
        transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (route) => false,
    );
  }


  // Pindah ke tab Pesanan.
  void _keTabPesanan({bool riwayat = false}) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            PesananScreens(mulaiDiRiwayat: riwayat),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: SafeArea(
        child: Column(
          children: [
            const TopNavigator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            icon: Icons.rate_review,
                            warna: AppColor.ungu,
                            angka: '$_jumlahUlasan',
                            label: 'Ulasan Wisata',
                            onTap: () =>
                                _keTabPesanan(riwayat: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            icon: Icons.favorite,
                            warna: AppColor.kuning,
                            angka: '$_jumlahWishlist',
                            label: 'Wishlist Liburan',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const WishlistScreens(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    _sectionTitle('AKUN SAYA'),

                    _group([
                      _MenuTile(
                        icon: Icons.person_outline,
                        judul: 'Edit Profil',
                        subjudul: 'Nama, email, nomor telepon',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const EditProfileScreens(),
                          ),
                        ),
                      ),
                    ]),

                    _sectionTitle('AKTIVITAS & RIWAYAT'),

                    _group([
                      _MenuTile(
                        icon: Icons.confirmation_number_outlined,
                        judul: 'Riwayat Pesanan & E-Tiket',
                        subjudul: _eTiketAktif > 0
                            ? '$_eTiketAktif E-Tiket aktif siap pakai'
                            : 'Belum ada E-Tiket aktif',
                        trailing: _eTiketAktif > 0
                            ? const Icon(
                                Icons.circle,
                                size: 8,
                                color: AppColor.kuning,
                              )
                            : null,
                        onTap: _keTabPesanan,
                      ),
                    ]),

                    _sectionTitle('PENGATURAN & BANTUAN'),

                    _group([
                      _MenuTile(
                        icon: Icons.lock_outline,
                        judul: 'Keamanan Akun',
                        subjudul: 'Atur Password',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const KeamananAkunScreens(),
                          ),
                        ),
                      ),
                      _MenuTile(
                        icon: Icons.shield_outlined,
                        judul: 'Syarat & Kebijakan Privasi',
                        subjudul: 'LokaTrip versi 3.14.0',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SnkScreens(),
                          ),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout,
                          size: 18,
                        ),
                        label: Text(
                          'Keluar dari Akun',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColor.kuning.withValues(alpha: 0.2),
                          foregroundColor: AppColor.kuning,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        'LokaTrip Indonesia © 2026 • Aman Terpercaya',
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
      bottomNavigationBar:
          const BottomNavigator(currentIndex: 3),
    );
  }

  // Nama, telepon, dan foto dari tabel users melalui ProfilStore.
  Widget _header() {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: ProfilStore.instance.profil,
      builder: (_, profil, _) {
        final nama =
            (profil?['nama_lengkap_user'] ?? '') as String;

        final telepon = ProfileService.keFormatLokal(
          (profil?['no_telephone'] ?? '') as String,
        );

        final foto = ProfilStore.instance.fotoUrl;
        final email = _email;

        return Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColor.biru,
              backgroundImage:
                  foto != null ? NetworkImage(foto) : null,
              child: foto == null
                  ? const Icon(
                      Icons.person,
                      size: 32,
                      color: AppColor.putih,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profil == null
                        ? 'Memuat...'
                        : (nama.isEmpty
                            ? 'Pengguna LokaTrip'
                            : nama),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),

                  const SizedBox(height: 2),

                  if (email.isNotEmpty)
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColor.hitam,
                      ),
                    ),

                  if (telepon.isNotEmpty)
                    Text(
                      telepon,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColor.hitam,
                      ),
                    ),
                ],
              ),
            ),

            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreens(),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColor.ungu,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color warna,
    required String angka,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: warna,
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  angka,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColor.abu,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String teks) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AppColor.hitam.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _group(List<Widget> children) {
    final isi = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      isi.add(children[i]);

      if (i != children.length - 1) {
        isi.add(
          Divider(
            height: 1,
            indent: 14,
            endIndent: 14,
            color: AppColor.abu.withValues(alpha: 0.25),
          ),
        );
      }
    }

    return Container(
      decoration: _cardDecoration(),
      child: Column(children: isi),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColor.putih,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: AppColor.hitam.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String judul;
  final String subjudul;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.judul,
    required this.subjudul,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.ungu.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColor.ungu,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subjudul,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: AppColor.abu,
                    ),
                  ),
                ],
              ),
            ),

            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 6),
            ],

            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColor.hitam,
            ),
          ],
        ),
      ),
    );
  }
}
