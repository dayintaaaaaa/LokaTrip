import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/gambar_wisata.dart';
import 'section_title.dart';

class DestinasiPopuler extends StatelessWidget {
  final List<Wisata> daftar;

  const DestinasiPopuler({super.key, required this.daftar});

  @override
  Widget build(BuildContext context) {
    final lebarKartu =
      (MediaQuery.of(context).size.width * 0.75).clamp(240.0, 320.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          judul: 'Destinasi Terpopuler',
          subjudul: 'Pilihan favorit para traveler pekan ini',
          warnaAksen: AppColor.biru,
          onLihatSemua: () {
            // nanti: buka halaman Wisata
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
            itemBuilder: (_, i) =>
                _KartuPopuler(wisata: daftar[i], lebar: lebarKartu),
          ),
        ),
      ],
    );
  }
}

class _KartuPopuler extends StatefulWidget {
  final Wisata wisata;
  final double lebar;

  const _KartuPopuler({required this.wisata, required this.lebar});

  @override
  State<_KartuPopuler> createState() => _KartuPopulerState();
}

class _KartuPopulerState extends State<_KartuPopuler> {
  bool _favorit = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.wisata;

    return Container(
      width: widget.lebar,
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
          // gambar + badge tipe + tombol hati
          SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GambarWisata(path: w.gambar),

                if (w.tipe != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.ungu,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 11, color: AppColor.putih),
                          const SizedBox(width: 3),
                          Text(
                            w.tipe!,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColor.putih,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _favorit = !_favorit),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColor.putih.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _favorit ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: _favorit
                            ? const Color(0xFFE5484D)
                            : AppColor.abu,
                      ),
                    ),
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
                // kategori + rating
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        (w.kategori ?? '').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColor.biru,
                        ),
                      ),
                    ),
                    if (w.rating != null) ...[
                      Icon(Icons.star_rounded,
                          size: 13, color: AppColor.kuning),
                      const SizedBox(width: 2),
                      Text(
                        '${w.rating}',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColor.hitam,
                        ),
                      ),
                      if (w.jumlahUlasan != null)
                        Text(
                          ' (${ringkasAngka(w.jumlahUlasan!)})',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // nama
                Text(
                  w.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 4),

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

                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: AppColor.abu.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 10),

                // harga + chip refund
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mulai dari',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: AppColor.abu,
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
                        ],
                      ),
                    ),
                    if (w.bisaRefund)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.biru.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Bisa Refund',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColor.biru,
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
    );
  }
}