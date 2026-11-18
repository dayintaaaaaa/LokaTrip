import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/ketersediaan_dummy.dart';

// Kartu "Jumlah Pengunjung": Dewasa, Anak, Bayi dengan tombol - dan +.
// Stateless: jumlah dan batasnya dipegang screen.
class JumlahPengunjung extends StatelessWidget {
  final int dewasa;
  final int anak;
  final int bayi;
  final int hargaDewasa;
  final int hargaAnak;
  final bool bisaTambahTiket; // dewasa + anak belum mencapai batas
  final bool bisaTambahBayi;
  final ValueChanged<int> onDewasa; // dikirim -1 atau +1
  final ValueChanged<int> onAnak;
  final ValueChanged<int> onBayi;

  const JumlahPengunjung({
    super.key,
    required this.dewasa,
    required this.anak,
    required this.bayi,
    required this.hargaDewasa,
    required this.hargaAnak,
    required this.bisaTambahTiket,
    required this.bisaTambahBayi,
    required this.onDewasa,
    required this.onAnak,
    required this.onBayi,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Jumlah Pengunjung',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColor.hitam,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pastikan data pengunjung sesuai dengan kartu identitas',
            style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
          ),
          const SizedBox(height: 8),
          _baris(
            judul: 'Dewasa (>12 tahun)',
            harga: hargaDewasa,
            jumlah: dewasa,
            bisaKurang: dewasa > 1, // minimal 1 dewasa sebagai wali
            bisaTambah: bisaTambahTiket,
            onUbah: onDewasa,
          ),
          _garis(),
          _baris(
            judul: 'Anak (3-12 tahun)',
            harga: hargaAnak,
            jumlah: anak,
            bisaKurang: anak > 0,
            bisaTambah: bisaTambahTiket,
            onUbah: onAnak,
          ),
          _garis(),
          _baris(
            judul: 'Bayi (<3 tahun)',
            harga: null,
            jumlah: bayi,
            bisaKurang: bayi > 0,
            bisaTambah: bisaTambahBayi,
            onUbah: onBayi,
          ),
          const SizedBox(height: 14),
          _catatan(),
        ],
      ),
    );
  }

  Widget _garis() =>
      Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.15));

  // harga null = gratis
  Widget _baris({
    required String judul,
    required int? harga,
    required int jumlah,
    required bool bisaKurang,
    required bool bisaTambah,
    required ValueChanged<int> onUbah,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 3),
                if (harga == null)
                  Text(
                    'Gratis (tanpa kursi)',
                    style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      color: AppColor.abu,
                    ),
                  )
                else
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formatRupiah(harga),
                          style: GoogleFonts.manrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColor.ungu,
                          ),
                        ),
                        TextSpan(
                          text: ' / orang',
                          style: GoogleFonts.manrope(
                            fontSize: 10.5,
                            color: AppColor.abu,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          _stepper(
            jumlah: jumlah,
            bisaKurang: bisaKurang,
            bisaTambah: bisaTambah,
            onUbah: onUbah,
          ),
        ],
      ),
    );
  }

  Widget _stepper({
    required int jumlah,
    required bool bisaKurang,
    required bool bisaTambah,
    required ValueChanged<int> onUbah,
  }) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tombol(Icons.remove, aktif: bisaKurang, terisi: false,
              onTap: () => onUbah(-1)),
          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                '$jumlah',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
            ),
          ),
          // tombol + terisi ungu kalau jumlahnya sudah lebih dari 0
          _tombol(Icons.add, aktif: bisaTambah, terisi: jumlah > 0,
              onTap: () => onUbah(1)),
        ],
      ),
    );
  }

  Widget _tombol(
    IconData ikon, {
    required bool aktif,
    required bool terisi,
    required VoidCallback onTap,
  }) {
    final isi = terisi && aktif;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aktif ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isi
              ? AppColor.ungu
              : aktif
                  ? AppColor.putih
                  : AppColor.ungu.withValues(alpha: 0.06),
          border: isi
              ? null
              : Border.all(
                  color: aktif
                      ? AppColor.abu.withValues(alpha: 0.2)
                      : Colors.transparent,
                ),
        ),
        child: Icon(
          ikon,
          size: 16,
          color: isi
              ? AppColor.putih
              : aktif
                  ? AppColor.ungu
                  : AppColor.abu.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _catatan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 15, color: AppColor.ungu),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Maksimal ${KetersediaanDummy.maksTiketPerTransaksi} tiket per '
              'transaksi. Anak usia di bawah 3 tahun wajib didampingi wali.',
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: AppColor.hitam.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}