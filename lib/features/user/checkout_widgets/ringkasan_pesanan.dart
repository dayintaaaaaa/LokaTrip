import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_tanggal.dart';
import '../../../models/data_pemesanan.dart';
import '../../../widgets/gambar_wisata.dart';

// Kartu ringkasan pesanan: wisata, paket, tanggal, dan jumlah pengunjung.
class RingkasanPesanan extends StatelessWidget {
  final DataPemesanan pesanan;
  final VoidCallback onUbah; // kembali ke Atur Jadwal & Pengunjung

  const RingkasanPesanan({
    super.key,
    required this.pesanan,
    required this.onUbah,
  });

  // "2 Dewasa, 1 Anak"
  String get _tamu {
    final p = pesanan;
    return [
      if (p.dewasa > 0) '${p.dewasa} Dewasa',
      if (p.anak > 0) '${p.anak} Anak',
      if (p.bayi > 0) '${p.bayi} Bayi',
    ].join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final p = pesanan;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label atas
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEFFA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'E-Tiket Instant',
                  style: GoogleFonts.manrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColor.ungu,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.check_circle_outline,
                size: 13,
                color: AppColor.ungu,
              ),
              const SizedBox(width: 3),
              Text(
                'Terkonfirmasi',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColor.ungu,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // gambar + judul + paket
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: GambarWisata(path: p.detail.gambar),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.detail.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.local_activity_outlined,
                            size: 13,
                            color: AppColor.ungu,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${p.grup.nama} • ${p.paket.namaPendek}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 10.5,
                              color: AppColor.abu,
                              height: 1.3,
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
          const SizedBox(height: 12),

          // jadwal + pengunjung
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: AppColor.ungu,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formatTanggalPendek(p.tanggal),
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColor.hitam,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onUbah,
                      child: Text(
                        'Ubah',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 15, color: AppColor.abu),
                    const SizedBox(width: 8),
                    Text(
                      _tamu,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}