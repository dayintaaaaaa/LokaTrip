
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format.dart';
import '../../core/session_manager.dart';
import '../../widgets/top_navigator.dart';
import '../../widgets/bottom_navigator.dart';
import '../../widgets/poin_card.dart';
import '../login_screens.dart';
import 'edit_profile_screens.dart';
import 'tukar_poin_screens.dart';
import 'riwayat_poin_screens.dart';
import 'wishlist_screens.dart';
import 'verifikasi_screens.dart';
import 'keamanan_akun_screens.dart';
import 'snk_screens.dart';
import 'pesanan_screens.dart';
import 'ulasan_wisata_screens.dart';

class AkunScreens extends StatefulWidget {
  const AkunScreens({super.key});

  @override
  State<AkunScreens> createState() => _AkunScreensState();
}

class _AkunScreensState extends State<AkunScreens> {
  // TODO: ganti dengan data dari backend
  final String _nama = 'Sarah Anindita';
  final String _email = 'sarah.anindita@email.com';
  final String _telepon = '+62 812-3456-7890';
  final int _saldoPoin = 24500;
  final int _jumlahUlasan = 24;
  final int _jumlahWishlist = 12;
  final int _eTiketAktif = 2;

  // ---------------- bottom sheet konfirmasi logout ----------------
  Future<bool> _konfirmasiLogout() async {
    final tebal = GoogleFonts.manrope(
      fontWeight: FontWeight.w800,
      color: AppColor.hitam,
    );

    final hasil = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColor.putih,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.abu.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 22),

              // ikon logout + gembok
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColor.kuning.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout_rounded,
                            size: 32, color: AppColor.kuning),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColor.putih,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.abu.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(Icons.lock_outline,
                            size: 13, color: AppColor.hitam),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Keluar dari Akun?',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
              const SizedBox(height: 10),

              Text.rich(
                TextSpan(
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    height: 1.55,
                    color: AppColor.hitam.withValues(alpha: 0.6),
                  ),
                  children: [
                    const TextSpan(text: 'Sesi Anda akan berakhir, namun semua '),
                    TextSpan(text: 'tiket aktif,', style: tebal.copyWith(fontSize: 12)),
                    const TextSpan(text: ' '),
                    TextSpan(
                        text: 'riwayat perjalanan',
                        style: tebal.copyWith(fontSize: 12)),
                    const TextSpan(text: ', dan '),
                    TextSpan(
                      text: '${formatAngka(_saldoPoin)} Loka-Poin',
                      style: tebal.copyWith(fontSize: 12, color: AppColor.ungu),
                    ),
                    const TextSpan(
                      text: ' Anda tetap tersimpan dengan aman di server kami.',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // kartu akun
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.ungu.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColor.abu.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColor.biru,
                      child: Icon(Icons.person, size: 22, color: AppColor.putih),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _nama,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.hitam,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColor.kuning.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColor.kuning.withValues(alpha: 0.7),
                                  ),
                                ),
                                child: Text(
                                  'GOLD TIER',
                                  style: GoogleFonts.manrope(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.hitam,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _email,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: AppColor.abu,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle,
                        size: 14, color: AppColor.ungu),
                    const SizedBox(width: 4),
                    Text(
                      'Tersimpan',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColor.ungu,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.info_outline,
                        size: 13, color: AppColor.abu),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Masuk kembali kapan saja dengan nomor handphone atau email terdaftar.',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        height: 1.4,
                        color: AppColor.abu,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // tombol keluar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.kuning.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx, true),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text(
                      'Ya, Keluar Akun',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kuning,
                      foregroundColor: AppColor.hitam,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // tombol batal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.ungu.withValues(alpha: 0.06),
                    foregroundColor: AppColor.hitam,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: AppColor.abu.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Text(
                    'Batal & Tetap Masuk',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // tap di luar sheet dianggap batal
    return hasil ?? false;
  }

  // ---------------- proses logout ----------------
  Future<void> _logout() async {
    final yakin = await _konfirmasiLogout();
    if (!yakin) return;

    await SessionManager.logout();
    if (!mounted) return;

    // pindah ke login dengan fade, semua halaman sebelumnya dihapus
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreens(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
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
            const TopNavigator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 16),

                    PoinCard(
                      saldo: _saldoPoin,
                      tier: 'GOLD TIER',
                      progressKiri: 'Menuju Island Master',
                      progressKanan: '550 Poin Lagi',
                      progress: 0.85,
                      footerKiri: 'Lvl 3: Explorer',
                      footerKanan: 'Dapatkan diskon 50% hotel',
                      onTukar: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TukarPoinScreens(),
                        ),
                      ),
                      onRiwayat: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RiwayatPoinScreens(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            icon: Icons.rate_review,
                            warna: AppColor.ungu,
                            angka: '$_jumlahUlasan',
                            label: 'Ulasan Wisata',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UlasanWisataScreens(),
                              ),
                            ),
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
                                builder: (_) => const WishlistScreens(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    _sectionTitle('INFORMASI PRIBADI & VERIFIKASI'),
                    _group([
                      _MenuTile(
                        icon: Icons.badge_outlined,
                        judul: 'Data Diri & KTP / Paspor',
                        subjudul: 'KTP Indonesia, Paspor RI',
                        trailing: _chipVerifikasi(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VerifikasiIdentitasScreens(),
                          ),
                        ),
                      ),
                    ]),

                    _sectionTitle('AKTIVITAS & RIWAYAT'),
                    _group([
                      _MenuTile(
                        icon: Icons.confirmation_number_outlined,
                        judul: 'Riwayat Pesanan & E-Tiket',
                        subjudul: '$_eTiketAktif E-Tiket aktif siap pakai',
                        trailing: const Icon(Icons.circle,
                            size: 8, color: AppColor.kuning),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PesananScreens(),
                          ),
                        ),
                      ),
                    ]),

                    _sectionTitle('PENGATURAN & BANTUAN'),
                    _group([
                      _MenuTile(
                        icon: Icons.lock_outline,
                        judul: 'Keamanan Akun & PIN',
                        subjudul: 'Atur Password',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KeamananAkunScreens(),
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
                        icon: const Icon(Icons.logout, size: 18),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
      bottomNavigationBar: const BottomNavigator(currentIndex: 4),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColor.biru,
              // TODO: ganti dengan foto dari backend (backgroundImage: NetworkImage(...))
              child: Icon(Icons.person, size: 32, color: AppColor.putih),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColor.ungu,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    size: 10, color: AppColor.putih),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nama,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _email,
                style: GoogleFonts.manrope(fontSize: 11, color: AppColor.hitam),
              ),
              Text(
                _telepon,
                style: GoogleFonts.manrope(fontSize: 11, color: AppColor.hitam),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreens()),
          ),
          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColor.ungu),
        ),
      ],
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
              child: Icon(icon, size: 18, color: warna),
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
                  style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
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
        isi.add(Divider(
          height: 1,
          indent: 14,
          endIndent: 14,
          color: AppColor.abu.withValues(alpha: 0.25),
        ));
      }
    }
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: isi),
    );
  }

  Widget _chipVerifikasi() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_outlined, size: 11, color: AppColor.ungu),
          const SizedBox(width: 3),
          Text(
            'Terverifikasi',
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColor.ungu,
            ),
          ),
        ],
      ),
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
              child: Icon(icon, size: 18, color: AppColor.ungu),
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
            const Icon(Icons.chevron_right, size: 18, color: AppColor.hitam),
          ],
        ),
      ),
    );
  }
}
