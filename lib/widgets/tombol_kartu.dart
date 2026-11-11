import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_color.dart';

// Tombol aksi di kartu wisata (Pilih Tiket / Pilih Paket / Pilih).
// Ukuran, radius, font, dan panahnya disamakan dengan tombol "Pesan Promo"
// di halaman Promo. Ubah di sini kalau mau mengganti semua tombol sekaligus.
class TombolKartu extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const TombolKartu({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.ungu,
        foregroundColor: AppColor.putih,
        elevation: 0,
        minimumSize: const Size(0, 40), // tinggi tombol promo = 40
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 14),
        ],
      ),
    );
  }
}