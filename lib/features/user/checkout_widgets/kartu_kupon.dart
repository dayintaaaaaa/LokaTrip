import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/kupon_dummy.dart';

// Kartu "Kupon & Promo": kupon terpasang (dengan tombol Hapus),
// atau kolom untuk memasukkan kode kupon kalau belum ada yang dipakai.
class KartuKupon extends StatelessWidget {
  final Kupon? kupon; // null = belum ada kupon terpasang
  final int diskon; // besar potongan dari kupon terpasang
  final TextEditingController kodeC;
  final String? error;
  final VoidCallback onPakai;
  final VoidCallback onHapus;

  const KartuKupon({
    super.key,
    required this.kupon,
    required this.diskon,
    required this.kodeC,
    required this.error,
    required this.onPakai,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              const Icon(
                Icons.local_offer_outlined,
                size: 18,
                color: AppColor.kuning,
              ),
              const SizedBox(width: 8),
              Text(
                'Kupon & Promo',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.hitam,
                ),
              ),
              const Spacer(),
              if (kupon != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEFFA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '1 Dipakai',
                    style: GoogleFonts.manrope(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColor.ungu,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (kupon != null) _terpasang(kupon!) else _masukkanKode(),
        ],
      ),
    );
  }

  Widget _terpasang(Kupon k) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            size: 20,
            color: AppColor.ungu,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k.kode,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColor.ungu,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hemat ${formatRupiah(diskon)} berhasil diaplikasikan',
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    color: AppColor.ungu.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onHapus,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Hapus',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColor.kuning,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _masukkanKode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: kodeC,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onPakai(),
                style: GoogleFonts.manrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColor.hitam,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan kode kupon',
                  hintStyle: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColor.abu,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FC),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onPakai,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.ungu,
                foregroundColor: AppColor.putih,
                elevation: 0,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Pakai',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: const Color(0xFFE53935),
            ),
          ),
        ],
      ],
    );
  }
}