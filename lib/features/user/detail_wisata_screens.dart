import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format_rupiah.dart';
import '../../models/detail_wisata.dart';
import '../../models/detail_wisata_dummy.dart';
import '../../models/wisata.dart';
import '../../widgets/gambar_wisata.dart';
import '../../widgets/tombol_favorit.dart';
import 'detail_widgets/fasilitas_tur.dart';
import 'detail_widgets/kartu_paket.dart';
import 'detail_widgets/ulasan_pengunjung.dart';
import '../user/atur_jadwal_screens.dart';

// 12800 -> "12.800"
String _ribuan(int n) => formatRupiah(n).replaceFirst('Rp ', '');

BoxDecoration _kotak({double radius = 14}) => BoxDecoration(
  color: AppColor.putih,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
);

class DetailWisataScreens extends StatefulWidget {
  final Wisata wisata;

  const DetailWisataScreens({super.key, required this.wisata});

  @override
  State<DetailWisataScreens> createState() => _DetailWisataScreensState();
}

class _DetailWisataScreensState extends State<DetailWisataScreens> {
  static const _latar = Color(0xFFF5F6FA);

  late final DetailWisata _d;
  int _grup = 0; // WNI / WNA
  int _paket = 0; // paket yang dipilih di kelompok itu

  GrupTiket get _g => _d.grup[_grup];
  PaketTiket get _p => _g.paket[_paket];

  @override
  void initState() {
    super.initState();
    _d = DetailDummy.untuk(widget.wisata);
  }

  void _gantiGrup(int i) {
    setState(() {
      _grup = i;
      _paket = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _latar,
        body: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _hero(),
                  const SizedBox(height: 14),
                  _barisBadge(),
                  Text(
                    _d.judul,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _barisRating(),
                  const SizedBox(height: 14),
                  _kartuLokasi(),
                  const SizedBox(height: 10),
                  _keunggulan(),
                  const SizedBox(height: 22),
                  _judulSeksi(
                    'Pilih Opsi Paket',
                    'Kategori tarif tiket masuk & tur',
                  ),
                  const SizedBox(height: 12),
                  if (_d.grup.length > 1) ...[
                    _pilihGrup(),
                    const SizedBox(height: 12),
                  ],
                  if (_g.catatan != null) ...[
                    _catatan(_g.catatan!),
                    const SizedBox(height: 10),
                  ],
                  for (var i = 0; i < _g.paket.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: KartuPaket(
                        paket: _g.paket[i],
                        dipilih: i == _paket,
                        onPilih: () => setState(() => _paket = i),
                      ),
                    ),
                  const SizedBox(height: 4),
                  FasilitasTur(
                    termasuk: _g.termasuk,
                    tidakTermasuk: _g.tidakTermasuk,
                  ),
                  const SizedBox(height: 22),
                  UlasanPengunjung(daftar: _d.ulasan),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _barPesan(),
      ),
    );
  }

  // ---------- header ----------

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.putih,
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppColor.hitam),
              ),
              Expanded(
                child: Text(
                  'Destination Detail',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- gambar utama ----------

  Widget _hero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 230,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GambarWisata(path: _d.gambar),

            // gelap tipis di bawah supaya label terbaca
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColor.hitam.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),

            // favorit + bagikan
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  TombolFavorit(wisataId: _d.wisataId),
                  _tombolBagikan(),
                ],
              ),
            ),

            // jumlah foto
            Positioned(
              left: 10,
              bottom: 10,
              child: _labelGambar(
                Icons.photo_camera_outlined,
                '1/${_d.jumlahFoto} Foto',
                gelap: true,
              ),
            ),

            // virtual tour
            if (_d.virtualTour)
              Positioned(
                right: 10,
                bottom: 10,
                child: _labelGambar(
                  Icons.view_in_ar_outlined,
                  'Virtual Tour',
                  gelap: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tombolBagikan() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // nanti: bagikan link wisata
      },
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColor.putih,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share_outlined,
              size: 15,
              color: AppColor.abu,
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelGambar(IconData ikon, String teks, {required bool gelap}) {
    final warna = gelap ? AppColor.putih : AppColor.hitam;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: gelap
            ? const Color(0xFF1A1A2E).withValues(alpha: 0.7)
            : AppColor.putih.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 12, color: warna),
          const SizedBox(width: 4),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- info utama ----------

  Widget _barisBadge() {
    if (_d.badge.isEmpty) return const SizedBox.shrink();
    const ikon = [Icons.verified_outlined, Icons.trending_up];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var i = 0; i < _d.badge.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEFFA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(ikon[i % ikon.length], size: 11, color: AppColor.ungu),
                  const SizedBox(width: 4),
                  Text(
                    _d.badge[i],
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColor.ungu,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _barisRating() {
    final r = _d.rating;
    if (r == null) return const SizedBox.shrink();
    final puas = _d.persenPuas;

    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColor.kuning),
        const SizedBox(width: 3),
        Text(
          '$r',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColor.hitam,
          ),
        ),
        if (_d.jumlahUlasan != null)
          Text(
            ' (${_ribuan(_d.jumlahUlasan!)} Ulasan)',
            style: GoogleFonts.manrope(fontSize: 11, color: AppColor.abu),
          ),
        if (puas != null) ...[
          const SizedBox(width: 12),
          const Icon(Icons.thumb_up_outlined, size: 13, color: AppColor.ungu),
          const SizedBox(width: 4),
          Text(
            '$puas% Puas',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColor.hitam,
            ),
          ),
        ],
      ],
    );
  }

  Widget _kartuLokasi() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _kotak(),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 22,
            color: AppColor.ungu,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _d.lokasi,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _d.wilayah,
                  style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // nanti: buka peta
            },
            child: Row(
              children: [
                Text(
                  'Lihat Peta',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColor.ungu,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: AppColor.ungu),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // grid 2 kolom: Konfirmasi Instan, Bebas Reschedule, dst.
  Widget _keunggulan() {
    final k = _d.keunggulan;

    return Column(
      children: [
        for (var i = 0; i < k.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < k.length ? 8 : 0),
            child: Row(
              children: [
                Expanded(child: _tileKeunggulan(k[i])),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < k.length
                      ? _tileKeunggulan(k[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tileKeunggulan((IconData, String, String) k) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _kotak(radius: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(k.$1, size: 15, color: AppColor.ungu),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                Text(
                  k.$3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- pilih paket ----------

  Widget _judulSeksi(String judul, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          judul,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColor.hitam,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
        ),
      ],
    );
  }

  // tombol geser WNI / WNA
  Widget _pilihGrup() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _d.grup.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => _gantiGrup(i),
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == _grup ? AppColor.ungu : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _d.grup[i].nama,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: i == _grup ? AppColor.putih : AppColor.ungu,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // kotak info biru, contoh: "Perhatian: Paspor / KITAS wajib ..."
  Widget _catatan(String teks) {
    final titik = teks.indexOf(':');
    final judul = titik == -1 ? '' : teks.substring(0, titik + 1);
    final isi = titik == -1 ? teks : teks.substring(titik + 1);
    final dasar = GoogleFonts.manrope(
      fontSize: 10,
      color: AppColor.hitam,
      height: 1.4,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.biru.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 15, color: AppColor.ungu),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: judul,
                    style: dasar.copyWith(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: isi, style: dasar),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- bar bawah ----------

  Widget _barPesan() {
    final p = _p;
    final satuan = p.satuan == '/orang' ? '/org' : p.satuan;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.putih,
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total mulai dari',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.abu,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatRupiah(p.harga),
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColor.ungu,
                            ),
                          ),
                          TextSpan(
                            text: ' $satuan',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: AppColor.abu,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (p.hargaUsd != null)
                      Text(
                        p.hargaUsd!,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          color: AppColor.abu,
                        ),
                      ),
                    Text(
                      p.namaPendek,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AturJadwalScreens(detail: _d, grup: _g, paket: _p),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.ungu,
                  foregroundColor: AppColor.putih,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pesan Sekarang',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
