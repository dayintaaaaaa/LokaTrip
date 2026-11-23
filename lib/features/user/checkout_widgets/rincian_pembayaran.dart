import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/data_checkout.dart';

// Kartu "Rincian Pembayaran": baris harga + Total Pembayaran.
// Total sama dengan total_bayar di database (harga tiket saja).
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
          _baris('Biaya Layanan', formatRupiah(r.biayaLayanan)),
          const SizedBox(height: 6),
          Divider(color: AppColor.ungu.withValues(alpha: 0.12)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Total Pembayaran',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
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

  Widget _baris(String kiri, String kanan, {bool gratis = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              kiri,
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                color: AppColor.hitam.withValues(alpha: 0.75),
              ),
            ),
          ),
          Text(
            kanan,
            style: GoogleFonts.manrope(
              fontSize: gratis ? 10 : 11.5,
              fontWeight: gratis ? FontWeight.w800 : FontWeight.w700,
              color: gratis ? AppColor.ungu : AppColor.hitam,
            ),
          ),
        ],
      ),
    );
  }
}