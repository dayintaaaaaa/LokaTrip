
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../core/app_color.dart';

import '../../models/data_checkout.dart';

import '../../core/format.dart';

import '../../widgets/qr_palsu.dart';

import 'e_tiket_screens.dart';

import 'home_screens.dart';

class BuktiTransaksiScreens extends StatelessWidget {
  final DataCheckout data;
  final String orderId;
  final String metode;

  const BuktiTransaksiScreens({
    super.key,
    required this.data,
    required this.orderId,
    required this.metode,
  });

  void _keBeranda(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreens()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // jangan balik ke halaman bayar setelah lunas
      child: Scaffold(
        backgroundColor: AppColor.latar,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    _bulat(Icons.close, () => _keBeranda(context)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'LOKATRIP CONCIERGE',
                            style: GoogleFonts.manrope(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColor.ungu,
                            ),
                          ),
                          Text(
                            'Bukti Transaksi',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColor.hitam,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _bulat(Icons.help_outline, () {}),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColor.ungu,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.biru.withValues(alpha: 0.5),
                          width: 5,
                        ),
                      ),
                      child: const Icon(Icons.check_rounded,
                          size: 34, color: AppColor.putih),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pembayaran Berhasil!',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'E-Tiket Anda telah terbit.',
                      style: GoogleFonts.manrope(
                          fontSize: 10, color: AppColor.abu),
                    ),
                    const SizedBox(height: 16),
                    _tiket(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ETiketScreens(
                              data: data,
                              kode: orderId,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.confirmation_number_outlined,
                            size: 17),
                        label: Text(
                          'Lihat E-Tiket Lengkap',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.ungu,
                          foregroundColor: AppColor.putih,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _keBeranda(context),
                        icon: const Icon(Icons.home_outlined,
                            size: 16, color: AppColor.abu),
                        label: Text(
                          'Kembali ke Beranda',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColor.hitam,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
    );
  }

  Widget _bulat(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColor.putih,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.hitam.withValues(alpha: 0.06),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColor.hitam),
      ),
    );
  }

  Widget _tiket() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.biru.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColor.kuning),
                    const SizedBox(width: 5),
                    Text(
                      'Lunas & Siap Digunakan',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColor.ungu,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'VOUCHER RESMI',
                style: GoogleFonts.manrope(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: AppColor.abu,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.explore_outlined,
                  size: 12, color: AppColor.ungu),
              const SizedBox(width: 4),
              Text(
                'TUR EKSKLUSIF',
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColor.ungu,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            data.pesanan.detail.judul,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColor.hitam,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.latar,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _info(
                    Icons.calendar_today_outlined,
                    'Tanggal Kunjungan',
                    tglPanjang(data.pesanan.tanggal),
                    data.pesanan.paket.durasi ?? 'Jadwal kunjungan',
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: AppColor.abu.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _info(
                    Icons.people_outline,
                    'Tamu',
                    '${data.pesanan.tiket} orang',
                    data.pesanan.paket.namaPendek,
                    warnaSub: AppColor.abu,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.25)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.hitam, width: 2),
                ),
                child: QrPalsu(
                  seed: orderId,
                  ukuran: 40,
                  logo: false,
                  warna: AppColor.hitam,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode Booking',
                      style: GoogleFonts.manrope(
                          fontSize: 9, color: AppColor.abu),
                    ),
                    Text(
                      orderId,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Terbayar',
                    style:
                        GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
                  ),
                  Text(
                    'Rp ${formatAngka(data.rincian.total)}',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColor.ungu,
                    ),
                  ),
                  Text(
                    metode,
                    style:
                        GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String label, String nilai, String sub,
      {Color warnaSub = AppColor.ungu}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: AppColor.abu),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            nilai,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColor.hitam,
            ),
          ),
          Text(
            sub,
            style: GoogleFonts.manrope(fontSize: 9, color: warnaSub),
          ),
        ],
      ),
    );
  }
}

String tglPanjang(DateTime tanggal) {
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
}
