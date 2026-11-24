
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api_client.dart';
import '../../core/app_color.dart';
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
            (result['jumlah_wishlist'] as num?)?.toInt() ?? 0;

        _jumlahUlasan =
            (result['jumlah_ulasan'] as num?)?.toInt() ?? 0;
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

  // Logout dari API dan hapus sesi lokal setelah konfirmasi.
  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    final token = await SessionManager.currentUserToken();

    if (token != null) {
      try {
        await UserApi.logout(token);
      } catch (_) {
        // Tetap hapus sesi lokal jika server tidak dapat dihubungi.
      }
    }

    await SessionManager.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreens(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
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
