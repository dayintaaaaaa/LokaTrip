import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_rupiah.dart';
import '../../../models/wisata.dart';
import '../../../widgets/badge_rating.dart';
import '../../../widgets/gambar_wisata.dart';
import '../../../widgets/tombol_favorit.dart';
import '../../../widgets/tombol_kartu.dart';
import '../../../core/navigasi_wisata.dart';

// Kartu dengan rating di atas gambar dan lokasi di bawah gambar.
class KartuLayanan extends StatelessWidget {
  final Wisata wisata;
  final VoidCallback? onTap;
  final String labelTombol; // contoh: 'Pilih Tiket' atau 'Pilih'
  final bool subkategoriDiGambar; // true = subkategori jadi label kanan bawah

  const KartuLayanan({
    super.key,
    required this.wisata,
    this.onTap,
    this.labelTombol = 'Pilih Tiket',
    this.subkategoriDiGambar = false,
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
                  // lokasi (+ subkategori kalau tidak dipindah ke gambar)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: AppColor.ungu),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: w.lokasi,
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: AppColor.abu,
                                ),
                              ),
                              if (!subkategoriDiGambar &&
                                  w.subkategori != null)
                                TextSpan(
                                  text: '  •  ${w.subkategori}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.ungu,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // nama
                  Text(
                    w.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),

                  // deskripsi
                  if (w.deskripsi != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      w.deskripsi!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                  ],

                  // chip fitur
                  if (w.fitur.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final f in w.fitur) _chipFitur(f)],
                    ),
                  ],
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
                                      color: AppColor.kuning
                                          .withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '-${w.diskonPersen}%',
                                      style: GoogleFonts.manrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: _hemat,
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

  // gambar + label atas + hati + rating + (subkategori)
  Widget _gambar(Wisata w) {
    return SizedBox(
      height: 125,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GambarWisata(path: w.gambar),

          // label kiri atas
          Positioned(
            top: 10,
            left: 10,
            right: 44,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (w.labelGambar != null) _badgeLabel(w.labelGambar!),
                if (w.tipe != null) _badgeTipe(w.tipe!),
              ],
            ),
          ),

          // hati: sama dengan halaman lain
          Positioned(top: 4, right: 6, child: TombolFavorit(wisataId: w.id)),

          // rating kiri bawah
          if (w.rating != null)
            Positioned(
              left: 10,
              bottom: 10,
              child: BadgeRating(
                rating: w.rating!,
                ulasan: w.jumlahUlasan == null
                    ? null
                    : '${ringkasAngka(w.jumlahUlasan!)} ulasan',
              ),
            ),

          // subkategori kanan bawah
          if (subkategoriDiGambar && w.subkategori != null)
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _gelap.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  w.subkategori!,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColor.putih,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // kuning kalau menandakan diskon/unggulan, selain itu putih
  Widget _badgeLabel(String teks) {
    final k = teks.toLowerCase();
    final kuning =
        k.contains('hemat') || k.contains('paling') || k.contains('best');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kuning ? AppColor.kuning : AppColor.putih.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!kuning) ...[
            Icon(_ikonLabel(k), size: 11, color: AppColor.ungu),
            const SizedBox(width: 3),
          ],
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: kuning ? _gelap : AppColor.ungu,
            ),
          ),
        ],
      ),
    );
  }

  IconData _ikonLabel(String k) {
    if (k.contains('edukasi')) return Icons.school_outlined;
    if (k.contains('petualangan') || k.contains('menantang')) {
      return Icons.hiking;
    }
    if (k.contains('keluarga') || k.contains('favorit')) {
      return Icons.family_restroom;
    }
    if (k.contains('camping') || k.contains('spot')) return Icons.park_outlined;
    return Icons.verified_outlined;
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

  Widget _chipFitur(String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_ikonFitur(teks), size: 11, color: AppColor.ungu),
          const SizedBox(width: 4),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColor.hitam,
            ),
          ),
        ],
      ),
    );
  }

  // ikon dipilih dari kata kunci di teks fitur
  IconData _ikonFitur(String teks) {
    final k = teks.toLowerCase();
    if (k.contains('teh') ||
        k.contains('jahe') ||
        k.contains('herbal') ||
        k.contains('ramuan')) {
      return Icons.local_cafe_outlined;
    }
    if (k.contains('view') || k.contains('kebun')) {
      return Icons.landscape_outlined;
    }
    if (k.contains('bathtub')) return Icons.bathtub_outlined;
    if (k.contains('paket') || k.contains('orang')) {
      return Icons.people_outline;
    }
    if (k.contains('kursi')) return Icons.event_seat_outlined;
    if (k.contains('guide') || k.contains('pemandu')) {
      return Icons.person_outline;
    }
    if (k.contains('trekking') || k.contains('jalur')) return Icons.hiking;
    if (k.contains('camping') || k.contains('tenda') || k.contains('kemah')) {
      return Icons.park_outlined;
    }
    if (k.contains('tiket') || k.contains('masuk')) {
      return Icons.confirmation_number_outlined;
    }
    return Icons.check_circle_outline;
  }
}