import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/hitung_mundur.dart';
import 'section_title.dart';

class FlashSaleSection extends StatelessWidget {
  final List<Wisata> daftar;
  final DateTime berakhirPada;

  const FlashSaleSection({
    super.key,
    required this.daftar,
    required this.berakhirPada,
  });

  @override
  Widget build(BuildContext context) {
    final lebarKartu =
        (MediaQuery.of(context).size.width * 0.72).clamp(240.0, 320.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          judul: 'Flash Sale Liburan',
          subjudul: 'Diskon fantastis s.d 50% kuota terbatas',
          warnaAksen: AppColor.kuning,
          aksesori: _chipTimer(),
          onLihatSemua: () {
            // nanti: buka halaman Flash Sale
          },
        ),
        const SizedBox(height: 14),

        // kartu geser ke samping
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: daftar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _kartu(daftar[i], lebarKartu),
          ),
        ),
      ],
    );
  }

  // chip timer: jam : menit : detik (angkanya dihitung oleh HitungMundur)
  Widget _chipTimer() {
    return HitungMundur(
      berakhirPada: berakhirPada,
      builder: (jam, menit, detik) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, size: 12, color: AppColor.putih),
            const SizedBox(width: 4),
            Text(
              '$jam : $menit : $detik',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColor.putih,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // satu kartu flash sale
  Widget _kartu(Wisata w, double lebar) {
    return Container(
      width: lebar,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // gambar + badge
          SizedBox(
            height: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GambarWisata(path: w.gambar),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _badge('% DISKON ${w.diskonPersen}%', AppColor.ungu),
                ),
                if (w.sisaTiket != null)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: _badge(
                      'Sisa ${w.sisaTiket} Tiket',
                      const Color(0xFF1A1A2E),
                    ),
                  ),
              ],
            ),
          ),

          // isi kartu
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // lokasi
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: AppColor.ungu),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        w.lokasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: AppColor.abu,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // nama
                Text(
                  w.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 8),

                // harga coret + harga diskon
                if (w.hargaAsli != null)
                  Text(
                    formatRupiah(w.hargaAsli!),
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColor.abu,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  formatRupiah(w.harga),
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColor.ungu,
                  ),
                ),
                const SizedBox(height: 10),

                // tombol
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      // nanti: klaim promo / buka detail wisata
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.ungu,
                      foregroundColor: AppColor.putih,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Klaim Promo',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // label kecil di atas gambar
  Widget _badge(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColor.putih,
        ),
      ),
    );
  }
}