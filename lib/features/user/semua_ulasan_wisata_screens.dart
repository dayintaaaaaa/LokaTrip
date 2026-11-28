import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../models/detail_wisata.dart';
import '../../models/wisata.dart';
import '../../services/wisata_service.dart';

class SemuaUlasanWisataScreens extends StatefulWidget {
  final Wisata wisata;

  const SemuaUlasanWisataScreens({super.key, required this.wisata});

  @override
  State<SemuaUlasanWisataScreens> createState() =>
      _SemuaUlasanWisataScreensState();
}

class _SemuaUlasanWisataScreensState extends State<SemuaUlasanWisataScreens> {
  late Future<List<UlasanDetail>> _future;

  @override
  void initState() {
    super.initState();
    _future = WisataService().ambilSemuaUlasanWisata(widget.wisata.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Semua Ulasan',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColor.hitam,
          ),
        ),
        backgroundColor: AppColor.putih,
        foregroundColor: AppColor.hitam,
        elevation: 0,
      ),
      body: FutureBuilder<List<UlasanDetail>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _pesanKosong(
              'Ulasan belum dapat dimuat. Coba lagi sebentar.',
              tombol: true,
            );
          }

          final ulasan = snapshot.data ?? const <UlasanDetail>[];
          if (ulasan.isEmpty) {
            return _pesanKosong('Belum ada ulasan untuk wisata ini.');
          }

          final rating =
              ulasan.map((u) => u.rating).reduce((a, b) => a + b) /
              ulasan.length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_outlined, color: AppColor.ungu),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      '${widget.wisata.nama} · ${widget.wisata.lokasi}',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ringkasan(rating, ulasan),
              const SizedBox(height: 16),
              for (final item in ulasan)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _KartuUlasan(
                    ulasan: item,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailUlasanWisataScreens(
                          wisata: widget.wisata,
                          ulasan: item,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _ringkasan(double rating, List<UlasanDetail> daftar) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: AppColor.ungu,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                child: Text('/ 5.0', style: _gaya(13, AppColor.abu)),
              ),
            ],
          ),
          Row(
            children: List.generate(
              5,
              (_) => const Icon(
                Icons.star_rounded,
                size: 23,
                color: AppColor.kuning,
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var bintang = 5; bintang >= 1; bintang--)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text('$bintang ★', style: _gaya(11, AppColor.abu)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: daftar.where((u) => u.rating.round() == bintang).length /
                            daftar.length,
                        backgroundColor: AppColor.biru.withValues(alpha: 0.15),
                        color: AppColor.ungu,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${(daftar.where((u) => u.rating.round() == bintang).length * 100 / daftar.length).round()}%',
                      textAlign: TextAlign.right,
                      style: _gaya(10, AppColor.abu),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 2),
          Text('${daftar.length} ulasan', style: _gaya(11, AppColor.abu)),
        ],
      ),
    );
  }

  Widget _pesanKosong(String teks, {bool tombol = false}) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(teks, textAlign: TextAlign.center, style: _gaya(13, AppColor.abu)),
          if (tombol) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => setState(() {
                _future = WisataService().ambilSemuaUlasanWisata(widget.wisata.id);
              }),
              child: const Text('Coba Lagi'),
            ),
          ],
        ],
      ),
    ),
  );
}

class DetailUlasanWisataScreens extends StatelessWidget {
  final Wisata wisata;
  final UlasanDetail ulasan;

  const DetailUlasanWisataScreens({
    super.key,
    required this.wisata,
    required this.ulasan,
  });

  @override
  Widget build(BuildContext context) {
    final inisial = ulasan.nama.isEmpty ? '?' : ulasan.nama[0].toUpperCase();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text('Detail Ulasan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: AppColor.putih,
        foregroundColor: AppColor.hitam,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.putih,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wisata.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColor.ungu.withValues(alpha: 0.12),
                      foregroundImage: ulasan.fotoProfil?.isNotEmpty == true
                          ? NetworkImage(ulasan.fotoProfil!)
                          : null,
                      child: Text(
                        inisial,
                        style: _gaya(15, AppColor.ungu, bold: true),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ulasan.nama, style: _gaya(13, AppColor.hitam, bold: true)),
                          const SizedBox(height: 2),
                          Text('${ulasan.asal} · ${ulasan.waktu}', style: _gaya(10, AppColor.abu)),
                        ],
                      ),
                    ),
                    const Icon(Icons.star_rounded, color: AppColor.kuning, size: 20),
                    Text(ulasan.rating.toStringAsFixed(1), style: _gaya(13, AppColor.hitam, bold: true)),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  ulasan.teks,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    height: 1.65,
                    color: AppColor.hitam.withValues(alpha: 0.86),
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

class _KartuUlasan extends StatelessWidget {
  final UlasanDetail ulasan;
  final VoidCallback onTap;

  const _KartuUlasan({required this.ulasan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inisial = ulasan.nama.isEmpty ? '?' : ulasan.nama[0].toUpperCase();
    return Material(
      color: AppColor.putih,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColor.ungu.withValues(alpha: 0.12),
                    foregroundImage: ulasan.fotoProfil?.isNotEmpty == true
                        ? NetworkImage(ulasan.fotoProfil!)
                        : null,
                    child: Text(inisial, style: _gaya(13, AppColor.ungu, bold: true)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ulasan.nama, style: _gaya(13, AppColor.hitam, bold: true)),
                        Text('${ulasan.asal} · ${ulasan.waktu}', style: _gaya(10, AppColor.abu)),
                      ],
                    ),
                  ),
                  const Icon(Icons.star_rounded, color: AppColor.kuning, size: 18),
                  Text(ulasan.rating.toStringAsFixed(1), style: _gaya(12, AppColor.hitam, bold: true)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ulasan.teks,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(fontSize: 12, height: 1.5, color: AppColor.hitam),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Baca Selengkapnya →', style: _gaya(11, AppColor.ungu, bold: true)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle _gaya(double size, Color color, {bool bold = false}) =>
    GoogleFonts.manrope(
      fontSize: size,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: color,
    );
