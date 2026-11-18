import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';
import '../../../widgets/tombol_kartu.dart';
import '../../../core/navigasi_wisata.dart';

class KartuKategori extends StatelessWidget {
  final Wisata wisata;
  final VoidCallback? onTap;

  final bool diskonOff; // true = chip biru "20% OFF", false = "Hemat 20%"

  const KartuKategori({
    super.key,
    required this.wisata,
    this.onTap,
    this.diskonOff = false,
  });

  static const _gelap = Color(0xFF1A1A2E);
  static const _hemat = Color(0xFF8A5A00);

  @override
  Widget build(BuildContext context) {
    final w = wisata;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColor.putih,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _gambar(w),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // nama
                  Text(
                    w.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // deskripsi
                  if (w.deskripsi != null) ...[
                    Text(
                      w.deskripsi!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // rating + ulasan + chip keterangan
                  Row(
                    children: [
                      if (w.rating != null) ...[
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColor.kuning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${w.rating}',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                      ],
                      if (w.jumlahUlasan != null)
                        Text(
                          '  •  ${ringkasAngka(w.jumlahUlasan!)} ulasan',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                      if (w.termasuk != null) ...[
                        Text(
                          '  •  ',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.biru.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              w.termasuk!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColor.ungu,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // harga + tombol
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (w.hargaAsli != null)
                              Row(
                                children: [
                                  Text(
                                    formatRupiah(w.hargaAsli!),
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: AppColor.abu,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: diskonOff
                                          ? AppColor.biru.withValues(
                                              alpha: 0.18,
                                            )
                                          : AppColor.kuning.withValues(
                                              alpha: 0.25,
                                            ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      diskonOff
                                          ? '${w.diskonPersen}% OFF'
                                          : 'Hemat ${w.diskonPersen}%',
                                      style: GoogleFonts.manrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: diskonOff
                                            ? AppColor.ungu
                                            : _hemat,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'Mulai dari',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                ),
                              ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: formatRupiah(w.harga),
                                    style: GoogleFonts.outfit(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.ungu,
                                    ),
                                  ),
                                  if (w.satuanHarga != null)
                                    TextSpan(
                                      text: ' ${w.satuanHarga}',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        color: AppColor.abu,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      TombolKartu(
                        label: 'Pilih Paket',
                        onPressed: () => bukaDetailWisata(context, wisata), // sesuaikan nama variabel (wisata / w)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // gambar + dua label + hati + lokasi
  Widget _gambar(Wisata w) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GambarWisata(path: w.gambar),

          // dua label kiri atas
          Positioned(
            top: 10,
            left: 10,
            right: 44,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (w.labelGambar != null) _badgeUtama(w.labelGambar!),
                if (w.tipe != null) _badgeTipe(w.tipe!),
              ],
            ),
          ),

          // hati: sama dengan halaman lain
          Positioned(top: 4, right: 6, child: TombolFavorit(wisataId: w.id)),

          // lokasi kiri bawah
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _gelap.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 11, color: AppColor.putih),
                  const SizedBox(width: 3),
                  Text(
                    w.lokasi,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColor.putih,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // kuning kalau label menandakan unggulan, selain itu putih
  Widget _badgeUtama(String teks) {
    final k = teks.toLowerCase();
    final unggulan =
        k.contains('paling') || k.contains('best') || k.contains('terlaris');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: unggulan
            ? AppColor.kuning
            : AppColor.putih.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _ikonBadge(teks, unggulan),
            size: 11,
            color: unggulan ? _gelap : AppColor.ungu,
          ),
          const SizedBox(width: 3),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: unggulan ? _gelap : AppColor.ungu,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeTipe(String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEFFA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppColor.ungu,
        ),
      ),
    );
  }

  IconData _ikonBadge(String teks, bool unggulan) {
    final k = teks.toLowerCase();
    if (unggulan) return Icons.local_fire_department_rounded;
    if (k.contains('instant')) return Icons.bolt;
    if (k.contains('tiket')) return Icons.confirmation_number_outlined;
    if (k.contains('wahana') || k.contains('kolam')) return Icons.pool;
    return Icons.account_balance_outlined;
  }
}
