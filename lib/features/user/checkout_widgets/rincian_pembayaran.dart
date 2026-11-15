import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/data_checkout.dart';

// Kartu "Rincian Pembayaran": baris harga + Total Pembayaran.
class RincianPembayaran extends StatelessWidget {
  final RincianHarga rincian;

  const RincianPembayaran({super.key, required this.rincian});

  @override
  Widget build(BuildContext context) {
    final r = rincian;
    final p = r.pesanan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rincian Pembayaran',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
              ),
              Icon(Icons.receipt_long_outlined, size: 18, color: AppColor.abu),
            ],
          ),
          const SizedBox(height: 10),
          _baris('Tiket Dewasa (${p.dewasa}x)', formatRupiah(r.tiketDewasa)),
          if (p.anak > 0)
            _baris('Tiket Anak (${p.anak}x)', formatRupiah(r.tiketAnak)),
          if (p.bayi > 0) _baris('Tiket Bayi (${p.bayi}x)', 'GRATIS'),
          if (r.careExtra)
            _baris(
              'Lokatrip Care Extra (${p.tiket}x)',
              formatRupiah(r.biayaCare),
            ),
          if (r.kupon != null)
            _baris(
              'Diskon Promo (${r.kupon!.kode})',
              '-${formatRupiah(r.diskon)}',
              warna: AppColor.ungu,
            ),
          _baris('Biaya Layanan & Pajak', 'GRATIS', gratis: true),
          const SizedBox(height: 6),
          Divider(color: AppColor.ungu.withValues(alpha: 0.12)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Termasuk seluruh retribusi resmi',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah(r.total),
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ungu,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _baris(
    String kiri,
    String kanan, {
    Color? warna,
    bool gratis = false,
  }) {
    final dasar = warna ?? AppColor.hitam;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              kiri,
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                color: warna ?? AppColor.hitam.withValues(alpha: 0.75),
              ),
            ),
          ),
          Text(
            kanan,
            style: GoogleFonts.manrope(
              fontSize: gratis ? 10 : 11.5,
              fontWeight: gratis ? FontWeight.w800 : FontWeight.w700,
              color: gratis ? AppColor.ungu : dasar,
            ),
          ),
        ],
      ),
    );
  }
}