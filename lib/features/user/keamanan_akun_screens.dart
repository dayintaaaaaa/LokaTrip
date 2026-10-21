import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../widgets/sub_app_bar.dart';

class KeamananAkunScreens extends StatefulWidget {
  const KeamananAkunScreens({super.key});

  @override
  State<KeamananAkunScreens> createState() => _KeamananAkunScreensState();
}

class _KeamananAkunScreensState extends State<KeamananAkunScreens> {
  // TODO: ganti dengan data dari backend
  bool _biometrik = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Keamanan Akun'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _banner(),

                  _sectionTitle('PENGATURAN KEAMANAN'),
                  _group([
                    _baris(
                      icon: Icons.dialpad,
                      judul: 'PIN Transaksi',
                      trailing: _teksAksi('Aktif'),
                      onTap: () {
                        // TODO: halaman atur PIN
                      },
                    ),
                    _baris(
                      icon: Icons.password,
                      judul: 'Kata Sandi',
                      trailing: _teksAksi('2 bln lalu', warna: AppColor.hitam),
                      onTap: () {
                        // TODO: halaman ganti kata sandi
                      },
                    ),
                    _baris(
                      icon: Icons.fingerprint,
                      judul: 'Masuk dengan Biometrik',
                      subjudul: 'Face ID / Sidik Jari',
                      trailing: Switch(
                        value: _biometrik,
                        onChanged: (v) => setState(() => _biometrik = v),
                        activeColor: AppColor.putih,
                        activeTrackColor: AppColor.ungu,
                        inactiveThumbColor: AppColor.putih,
                        inactiveTrackColor: AppColor.abu.withValues(alpha: 0.4),
                      ),
                    ),
                    _baris(
                      icon: Icons.verified_user_outlined,
                      judul: 'Verifikasi 2 Langkah (2FA)',
                      trailing: _teksAksi('Aktif'),
                      onTap: () {
                        // TODO: halaman 2FA
                      },
                    ),
                  ]),

                  _sectionTitle('PERANGKAT & SESI'),
                  _kartuPerangkat(),

                  _sectionTitle('AKTIVITAS & LOG MASUK'),
                  _group([
                    _baris(
                      icon: Icons.history,
                      judul: 'Riwayat Masuk Akun',
                      subjudul: 'Jakarta, Indonesia • Hari ini, 09:42 WIB',
                      trailing: _chip('Berhasil', AppColor.biru),
                      tampilChevron: false,
                      onTap: () {
                        // TODO: halaman riwayat login
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== BANNER ==================
  Widget _banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.biru.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.biru.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_outlined,
                size: 18, color: AppColor.ungu),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akun Terlindungi',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColor.ungu,
                  ),
                ),
                Text(
                  'Semua fitur perlindungan utama aktif',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColor.hitam.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          _chip('Optimal', AppColor.biru),
        ],
      ),
    );
  }

  // ================== PERANGKAT ==================
  Widget _kartuPerangkat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ikonKotak(Icons.phone_iphone),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'iPhone 15 Pro',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perangkat ini • Aktif sekarang',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ),
              _chip('Utama', AppColor.ungu),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.25)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 perangkat lain terhubung',
                style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
              ),
              InkWell(
                onTap: () {
                  // TODO: keluar dari perangkat lain
                },
                child: Text(
                  'Keluar dari perangkat lain',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.kuning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== KOMPONEN ==================
  Widget _baris({
    required IconData icon,
    required String judul,
    String? subjudul,
    Widget? trailing,
    bool tampilChevron = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColor.abu),
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
                  if (subjudul != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subjudul,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing is! Switch && tampilChevron)
              const Icon(Icons.chevron_right, size: 16, color: AppColor.hitam),
          ],
        ),
      ),
    );
  }

  Widget _teksAksi(String teks, {Color warna = AppColor.ungu}) {
    return Text(
      teks,
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: warna,
      ),
    );
  }

  Widget _chip(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: warna,
        ),
      ),
    );
  }

  Widget _ikonKotak(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColor.ungu),
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