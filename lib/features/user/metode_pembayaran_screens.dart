import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_color.dart';
import '../../core/format_rupiah.dart';
import '../../models/data_checkout.dart';
import 'pembayaran_screens.dart';

class MetodePembayaranScreens extends StatefulWidget {
  final DataCheckout data;

  const MetodePembayaranScreens({super.key, required this.data});

  @override
  State<MetodePembayaranScreens> createState() =>
      _MetodePembayaranScreensState();
}

class _MetodePembayaranScreensState extends State<MetodePembayaranScreens> {
  static const _metode = [
    (
      nama: 'Virtual Account',
      detail: 'BCA, Mandiri, BNI, BRI',
      ikon: Icons.account_balance_outlined,
      jenis: 1,
    ),
    (
      nama: 'E-Wallet',
      detail: 'GoPay, OVO, DANA, ShopeePay',
      ikon: Icons.account_balance_wallet_outlined,
      jenis: 2,
    ),
    (
      nama: 'QRIS',
      detail: 'Bayar dengan scan kode QR',
      ikon: Icons.qr_code_2,
      jenis: 0,
    ),
    (
      nama: 'Kartu Kredit / Debit',
      detail: 'Visa, Mastercard',
      ikon: Icons.credit_card_outlined,
      jenis: 3,
    ),
  ];

  int _terpilih = 0;

  void _lanjut() {
    final metode = _metode[_terpilih];
    final orderId = 'LKT-${DateTime.now().millisecondsSinceEpoch}';

    final halaman = metode.jenis == 0
        ? QrisScreens(data: widget.data, orderId: orderId)
        : PembayaranLainScreens(
            data: widget.data,
            orderId: orderId,
            metode: metode.nama,
            jenis: metode.jenis,
          );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => halaman),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      appBar: AppBar(
        backgroundColor: AppColor.putih,
        foregroundColor: AppColor.hitam,
        elevation: 0,
        title: Text(
          'Metode Pembayaran',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.putih,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pembayaran',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColor.abu,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(widget.data.rincian.total),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColor.ungu,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Pilih metode pembayaran',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColor.hitam,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _metode.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColor.putih,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _terpilih == i
                      ? AppColor.ungu
                      : AppColor.abu.withValues(alpha: 0.2),
                ),
              ),
              child: RadioListTile<int>(
                value: i,
                groupValue: _terpilih,
                activeColor: AppColor.ungu,
                onChanged: (v) {
                  if (v != null) setState(() => _terpilih = v);
                },
                title: Text(
                  _metode[i].nama,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                subtitle: Text(
                  _metode[i].detail,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColor.abu,
                  ),
                ),
                secondary: Icon(
                  _metode[i].ikon,
                  color: AppColor.ungu,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _lanjut,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.ungu,
                foregroundColor: AppColor.putih,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lanjutkan Pembayaran',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
