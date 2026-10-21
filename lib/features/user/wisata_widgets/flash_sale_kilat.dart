import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/hitung_mundur.dart';

class FlashSaleKilat extends StatelessWidget {
  final List<Wisata> daftar;
  final DateTime berakhirPada;

  const FlashSaleKilat({
    super.key,
    required this.daftar,
    required this.berakhirPada,
  });

  static const _amber = Color(0xFFD98E00);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header: ikon + judul + timer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColor.kuning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bolt, size: 18, color: AppColor.putih),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flash Sale Kilat',
                      style: GoogleFonts.rubik(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                    Text(
                      'Diskon terbesar hari ini',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ),
              HitungMundur(
                berakhirPada: berakhirPada,
                builder: (jam, menit, detik) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.kuning),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: _amber),
                      const SizedBox(width: 4),
                      Text(
                        '$jam : $menit : $detik',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // kartu geser ke samping
        if (daftar.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Belum ada flash sale di lokasi ini',
              style: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
            ),
          )
        else
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: daftar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _kartu(daftar[i]),
            ),
          ),
      ],
    );
  }

  Widget _kartu(Wisata w) {
    final terjual = (w.terjualPersen ?? 0) / 100;
    final teksStok = w.sisaTiket != null
        ? 'Sisa ${w.sisaTiket} tiket lagi'
        : 'Terjual ${w.terjualPersen ?? 0}%';

    return Container(
      width: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // gambar + badge diskon
          SizedBox(
            height: 105,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GambarWisata(path: w.gambar),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColor.kuning,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-${w.diskonPersen}%',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // isi kartu
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 6),
                if (w.hargaAsli != null)
                  Text(
                    formatRupiah(w.hargaAsli!),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: AppColor.abu,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  formatRupiah(w.harga),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.ungu,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: terjual,
                    minHeight: 6,
                    color: AppColor.kuning,
                    backgroundColor: AppColor.abu.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teksStok,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColor.abu,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}