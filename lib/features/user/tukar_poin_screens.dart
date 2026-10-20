import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format.dart';
import '../../widgets/sub_app_bar.dart';
import '../../widgets/poin_card.dart';

// TODO: ganti model ini dengan model dari backend
class _Kupon {
  final String badge;
  final String kategori;
  final String? label; // "Semua Hari", "Favorit Member", dst
  final Color warnaKategori;
  final String judul;
  final String info;
  final IconData infoIcon;
  final int harga;
  final String teksTombol;

  const _Kupon({
    required this.badge,
    required this.kategori,
    this.label,
    required this.warnaKategori,
    required this.judul,
    required this.info,
    required this.infoIcon,
    required this.harga,
    this.teksTombol = 'Tukar Kupon',
  });
}

class TukarPoinScreens extends StatefulWidget {
  const TukarPoinScreens({super.key});

  @override
  State<TukarPoinScreens> createState() => _TukarPoinScreensState();
}

class _TukarPoinScreensState extends State<TukarPoinScreens> {
  final int _saldoPoin = 24500; // TODO: dari backend

  final List<_Kupon> _daftar = const [
    _Kupon(
      badge: 'WISATA',
      kategori: 'LOKATRIP WISATA',
      label: 'Kupon Digital',
      warnaKategori: AppColor.biru,
      judul: 'Potongan Rp 50.000 Tiket Candi Borobudur & VW Safari',
      info: 'Berlaku 30 hari pasca tukar',
      infoIcon: Icons.calendar_today_outlined,
      harga: 5000,
    ),
    _Kupon(
      badge: 'HIBURAN',
      kategori: 'TAMAN HIBURAN',
      label: 'Semua Hari',
      warnaKategori: AppColor.biru,
      judul: 'Diskon Rp 150.000 Waterbom Bali / Theme Park Nusantara',
      info: 'Min. transaksi Rp 300.000',
      infoIcon: Icons.receipt_long_outlined,
      harga: 15000,
    ),
    _Kupon(
      badge: 'HOTEL',
      kategori: 'HOTEL & PENGINAPAN',
      label: 'Favorit Member',
      warnaKategori: AppColor.kuning,
      judul: 'Voucher Diskon Hotel & Resort Rp 200.000',
      info: 'Hotel Bintang 4 & 5 di Bali & Jogja',
      infoIcon: Icons.apartment_outlined,
      harga: 20000,
    ),
    _Kupon(
      badge: 'FISIK',
      kategori: 'MERCHANDISE EKSKLUSIF',
      warnaKategori: AppColor.ungu,
      judul: 'Gratis Lokatrip Travel Pouch & E-Money Saldo Rp 50.000',
      info: 'Dikirim gratis ke alamat rumah',
      infoIcon: Icons.local_shipping_outlined,
      harga: 12000,
      teksTombol: 'Tukar Hadiah',
    ),
    _Kupon(
      badge: 'PREMIUM',
      kategori: 'TUR MEWAH KOMODO',
      warnaKategori: AppColor.kuning,
      judul: 'Voucher Tur Privat Komodo Phinisi VIP Rp 500.000',
      info: 'Berlaku hingga 6 bulan ke depan',
      infoIcon: Icons.calendar_today_outlined,
      harga: 45000,
    ),
  ];

  void _tukar(_Kupon k) {
    // TODO: panggil API penukaran poin
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Penukaran "${k.badge}" diproses',
          style: GoogleFonts.manrope(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Keuntungan Lokaelite'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PoinCard(
                    saldo: _saldoPoin,
                    tier: 'GOLD TIER',
                    subtitle: 'Setara nilai hemat hingga Rp 245.000',
                    progressKiri: 'Menuju Island Master (Lvl 4)',
                    progressKanan: '550 Poin Lagi',
                    progress: 0.85,
                    footerKiri:
                        'Keuntungan: Diskon hotel 50% & prioritas check-in',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rekomendasi Penukaran',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                      ),
                      Text(
                        '${_daftar.length} Kupon Tersedia',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: AppColor.abu,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._daftar.map(_kartuKupon),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuKupon(_Kupon k) {
    final cukup = _saldoPoin >= k.harga;
    final kurang = k.harga - _saldoPoin;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // gambar kupon (placeholder)
              // TODO: ganti dengan Image.network(gambarDariBackend)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: k.warnaKategori.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.image_outlined,
                          color: k.warnaKategori, size: 28),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColor.putih,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          k.badge,
                          style: GoogleFonts.manrope(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: AppColor.ungu,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: k.kategori,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: k.warnaKategori,
                        ),
                        children: [
                          if (k.label != null)
                            TextSpan(
                              text: '  •  ${k.label}',
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: k.warnaKategori,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      k.judul,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(k.infoIcon, size: 11, color: AppColor.abu),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            k.info,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              color: AppColor.abu,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // harga + tombol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: cukup
                  ? AppColor.latar
                  : AppColor.ungu.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.monetization_on_rounded,
                  size: 20,
                  color: cukup ? AppColor.kuning : AppColor.abu,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatAngka(k.harga),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    Text(
                      'LOKA-POIN',
                      style: GoogleFonts.manrope(
                        fontSize: 8,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: cukup ? () => _tukar(k) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.ungu,
                    foregroundColor: AppColor.putih,
                    disabledBackgroundColor:
                        AppColor.abu.withValues(alpha: 0.2),
                    disabledForegroundColor: AppColor.abu,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    cukup ? k.teksTombol : 'Poin Belum Cukup',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!cukup)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Kurang ${formatAngka(kurang)} Poin',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColor.kuning,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}