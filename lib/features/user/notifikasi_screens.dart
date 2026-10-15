import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../widgets/bottom_navigator.dart';

class _Notif {
  final IconData icon;
  final Color warna; // warna ikon, label, dan titik
  final String label;
  final String waktu;
  final String judul;
  final String isi;
  final String? sorot; // kata yang diberi warna di dalam isi
  final bool baru;

  const _Notif({
    required this.icon,
    required this.warna,
    required this.label,
    required this.waktu,
    required this.judul,
    required this.isi,
    this.sorot,
    this.baru = false,
  });
}

class NotifikasiScreens extends StatelessWidget {
  const NotifikasiScreens({super.key});

  static const _terbaru = [
    _Notif(
      icon: Icons.confirmation_number_outlined,
      warna: AppColor.ungu,
      label: 'TRANSAKSI BERHASIL',
      waktu: '10 mnt lalu',
      judul: 'E-Tiket Terbit: Waterbom Bali Day Pass',
      isi:
          'Pembayaran terverifikasi! Kode booking #LKT-89210492 sudah siap digunakan.',
      baru: true,
    ),
    _Notif(
      icon: Icons.local_fire_department_outlined,
      warna: AppColor.kuning,
      label: 'KUPON TERBATAS',
      waktu: '2 jam lalu',
      judul: 'Flash Sale 50% Borobudur Sunrise',
      isi:
          'Tersisa 4 kuota tiket spesial pagi ini! Gunakan kupon FLASH50 sebelum jam...',
      sorot: 'FLASH50',
      baru: true,
    ),
    _Notif(
      icon: Icons.event_available_outlined,
      warna: AppColor.ungu,
      label: 'PENGINGAT WISATA',
      waktu: '5 jam lalu',
      judul: 'Besok ke VW Safari Borobudur',
      isi:
          'Jadwal tur Anda besok Sabtu pukul 05:00 WIB di Dagi Hill. Pastikan tiba 15 menit lebih',
      baru: true,
    ),
  ];

  static const _terdahulu = [
    _Notif(
      icon: Icons.sell_outlined,
      warna: AppColor.hitam,
      label: 'VOUCHER MINGGUAN',
      waktu: 'Kemarin, 14:20',
      judul: 'Kupon Diskon Rp 50.000 Menunggumu',
      isi:
          'Kupon diskon hemat berlaku untuk pemesanan tiket candi, outbound, dan...',
    ),
    _Notif(
      icon: Icons.shield_outlined,
      warna: AppColor.hitam,
      label: 'KEAMANAN AKUN',
      waktu: '3 hari lalu',
      judul: 'Login Akun Baru Terdeteksi',
      isi:
          'Akun Anda baru saja masuk dari perangkat Android di Yogyakarta. Abaikan jika ini...',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.ungu.withValues(alpha: 0.05),
      appBar: AppBar(
        backgroundColor: AppColor.putih,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: AppColor.hitam, size: 22),
        ),
        titleSpacing: 0,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColor.hitam,
          ),
        ),
        actions: [
          // tandai semua dibaca
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.done_all, color: AppColor.ungu, size: 20),
          ),
          // avatar kecil
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.abu.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.person, size: 16, color: AppColor.abu),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        children: [
          // ---- Terbaru ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Terbaru',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
              const Spacer(),
              Text(
                '3 BELUM DIBACA',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColor.ungu,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._terbaru.map((n) => _NotifCard(n)),

          // ---- Terdahulu ----
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Terdahulu',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
              const Spacer(),
              Text(
                'Sudah dibaca',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColor.abu,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._terdahulu.map((n) => _NotifCard(n)),
        ],
      ),
      // tidak ada tab yang aktif di halaman ini
      bottomNavigationBar: const BottomNavigator(currentIndex: -1),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _Notif n;
  const _NotifCard(this.n);

  @override
  Widget build(BuildContext context) {
    final bool terdahulu = !n.baru;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ikon bulat
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: terdahulu
                  ? AppColor.ungu.withValues(alpha: 0.1)
                  : n.warna.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              n.icon,
              size: 20,
              color: terdahulu ? AppColor.hitam.withValues(alpha: 0.7) : n.warna,
            ),
          ),
          const SizedBox(width: 12),

          // isi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // label + waktu + titik
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        n.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: terdahulu
                              ? AppColor.hitam.withValues(alpha: 0.7)
                              : n.warna,
                        ),
                      ),
                    ),
                    Text(
                      n.waktu,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: terdahulu ? AppColor.abu : AppColor.hitam,
                      ),
                    ),
                    if (n.baru) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: n.warna,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),

                // judul
                Text(
                  n.judul,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),

                // isi (maks 2 baris)
                _isi(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // isi singkat, kata sorotan (mis. kode kupon) diberi warna ungu
  Widget _isi() {
    final dasar = GoogleFonts.manrope(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: AppColor.hitam.withValues(alpha: 0.65),
      height: 1.45,
    );

    final sorot = n.sorot;
    if (sorot == null || !n.isi.contains(sorot)) {
      return Text(
        n.isi,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: dasar,
      );
    }

    final bagian = n.isi.split(sorot);
    return Text.rich(
      TextSpan(
        style: dasar,
        children: [
          TextSpan(text: bagian.first),
          TextSpan(
            text: sorot,
            style: dasar.copyWith(
              color: AppColor.ungu,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: bagian.sublist(1).join(sorot)),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}