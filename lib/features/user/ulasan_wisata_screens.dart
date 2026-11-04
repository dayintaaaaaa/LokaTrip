import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format.dart';
import '../../widgets/sub_app_bar.dart';

TextStyle _gaya(
  double size, {
  FontWeight w = FontWeight.w500,
  Color c = AppColor.hitam,
  double? h,
  double? ls,
}) =>
    GoogleFonts.manrope(
      fontSize: size,
      fontWeight: w,
      color: c,
      height: h,
      letterSpacing: ls,
    );

const _namaBulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _tglHariIni() {
  final d = DateTime.now();
  return '${d.day} ${_namaBulan[d.month - 1]} ${d.year}';
}

BoxDecoration _kartu() => BoxDecoration(
      color: AppColor.putih,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: AppColor.hitam.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

// foto placeholder, TODO: ganti dengan Image.asset / Image.network dari backend
Widget _fotoPlaceholder(
  int variasi,
  double tinggi, {
  double? lebar,
  double radius = 10,
}) {
  final warna = variasi.isEven
      ? [AppColor.biru, AppColor.ungu]
      : [AppColor.kuning, AppColor.biru];
  return Container(
    height: tinggi,
    width: lebar,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: warna,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Icon(
      Icons.image_outlined,
      size: 22,
      color: AppColor.putih.withValues(alpha: 0.7),
    ),
  );
}

Widget _chipKategori(String teks) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColor.biru.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        teks,
        style: _gaya(9.5, w: FontWeight.w700, c: AppColor.ungu),
      ),
    );

// ======================= model & data dummy =======================
// TODO: ganti model dan data ini dengan yang dari backend

// tiket yang sudah dipakai (bahan untuk ulasan)
class _Pesanan {
  final String judul;
  final String kategori;
  final String paket;
  final String noPesanan;
  final String tglPakai;
  final List<String> pilihanAspek;

  const _Pesanan({
    required this.judul,
    required this.kategori,
    required this.paket,
    required this.noPesanan,
    required this.tglPakai,
    required this.pilihanAspek,
  });
}

class _Ulasan {
  final _Pesanan pesanan;
  double rating;
  List<String> aspek;
  String teks;
  List<String> foto;
  int terbantu;
  String tglUlasan;

  _Ulasan({
    required this.pesanan,
    required this.rating,
    required this.aspek,
    required this.teks,
    required this.foto,
    required this.terbantu,
    required this.tglUlasan,
  });
}

enum _HasilForm { dikirim, disimpan, dihapus }

class _DataUlasan {
  // angka ringkasan di bagian atas halaman
  static double rataRata = 4.8;
  static int total = 24;
  static int foto = 18;
  static int poin = 1200;

  static final List<_Ulasan> sudah = [
    _Ulasan(
      pesanan: const _Pesanan(
        judul: 'Candi Borobudur Sunrise & VW Safari',
        kategori: 'Tur Budaya',
        paket: 'Paket Domestik',
        noPesanan: '#LKT-8592014',
        tglPakai: '15 Sep 2024',
        pilihanAspek: [
          'Pemandangan Sunrise Indah',
          'Pemandu Ramah & Edukatif',
          'Fasilitas Bersih',
          'Tepat Waktu',
          'Makanan Enak',
          'Ramah Anak',
        ],
      ),
      rating: 5,
      aspek: [
        'Pemandangan Sunrise Indah',
        'Pemandu Ramah & Edukatif',
        'Fasilitas Bersih',
      ],
      teks:
          'Sunrise di Dagi Hill magis banget! Sandal upanat sangat nyaman dan edukasi pemandunya detail tentang relief Karmawibhangga. VW safarinya seru keliling desa Karanganyar.',
      foto: ['foto_1.jpg', 'foto_2.jpg', 'foto_3.jpg'],
      terbantu: 142,
      tglUlasan: '18 Okt 2024',
    ),
    _Ulasan(
      pesanan: const _Pesanan(
        judul: 'Waterbom Bali - Day Pass All Rides',
        kategori: 'Taman Rekreasi Air',
        paket: 'Single Day Pass',
        noPesanan: '#LKT-8420175',
        tglPakai: '20 Sep 2024',
        pilihanAspek: [
          'Antre Cepat',
          'Wahana Seru',
          'Fasilitas Bersih',
          'Ramah Anak',
          'Harga Sepadan',
          'Tepat Waktu',
        ],
      ),
      rating: 3.5,
      aspek: ['Antre Cepat', 'Wahana Seru'],
      teks:
          'Proses scan tiket QR di pintu masuk sangat cepat tanpa antre tiket fisik lagi. Wahana Climax dan Boomerang juara! Fasilitas loker dan gazebo bersih terawat.',
      foto: ['foto_1.jpg', 'foto_2.jpg'],
      terbantu: 89,
      tglUlasan: '23 Sep 2024',
    ),
    _Ulasan(
      pesanan: const _Pesanan(
        judul: 'Lava Tour Merapi Jeep Adventure',
        kategori: 'Petualangan Alam',
        paket: 'Rute Bunker Kali Kuning',
        noPesanan: '#LKT-8311902',
        tglPakai: '10 Agu 2024',
        pilihanAspek: [
          'Driver Ramah',
          'Sesi Foto Seru',
          'Rute Menantang',
          'Jeep Terawat',
          'Aman',
          'Tepat Waktu',
        ],
      ),
      rating: 4,
      aspek: ['Driver Ramah', 'Rute Menantang'],
      teks:
          'Sangat memacu adrenalin terutama sesi manuver air di Kali Kuning! Driver berpengalaman dan ramah membantu sesi foto keluarga.',
      foto: [],
      terbantu: 54,
      tglUlasan: '12 Agu 2024',
    ),
  ];

  static final List<_Pesanan> belum = [
    const _Pesanan(
      judul: 'GWK Cultural Park Bali - Pertunjukan Tari Kecak & Sunset',
      kategori: 'Taman Budaya',
      paket: 'Paket Reguler',
      noPesanan: '#LKT-8910482',
      tglPakai: '20 Okt 2024',
      pilihanAspek: [
        'Pertunjukan Megah',
        'Pemandangan Sunset Indah',
        'Pemandu Ramah',
        'Tepat Waktu',
        'Fasilitas Bersih',
        'Ramah Anak',
      ],
    ),
    const _Pesanan(
      judul: 'Rafting Sungai Ayung Ubud + Buffet Lunch',
      kategori: 'Petualangan Alam',
      paket: 'Single Day Pass',
      noPesanan: '#LKT-8749210',
      tglPakai: '15 Okt 2024',
      pilihanAspek: [
        'Arus Seru',
        'Pemandu Ramah',
        'Peralatan Aman',
        'Pemandangan Indah',
        'Makan Siang Enak',
        'Ramah Pemula',
      ],
    ),
  ];

  static void tambah(_Ulasan u, int bonusPoin) {
    belum.remove(u.pesanan);
    sudah.insert(0, u);
    rataRata = (rataRata * total + u.rating) / (total + 1);
    total += 1;
    foto += u.foto.length;
    poin += 100 + bonusPoin;
  }

  static void ubah(
    _Ulasan u, {
    required double rating,
    required List<String> aspek,
    required String teks,
    required List<String> fotoBaru,
  }) {
    rataRata = (rataRata * total - u.rating + rating) / total;
    foto += fotoBaru.length - u.foto.length;
    u.rating = rating;
    u.aspek = aspek;
    u.teks = teks;
    u.foto = fotoBaru;
  }

  static void hapus(_Ulasan u) {
    sudah.remove(u);
    belum.insert(0, u.pesanan);
    rataRata = total > 1 ? (rataRata * total - u.rating) / (total - 1) : 0;
    total -= 1;
    foto -= u.foto.length;
  }
}

// ======================= halaman daftar ulasan =======================
class UlasanWisataScreens extends StatefulWidget {
  // dipertahankan supaya pesanan_screens.dart yang lama tidak error
  final String? orderId;

  const UlasanWisataScreens({super.key, this.orderId});

  @override
  State<UlasanWisataScreens> createState() => _UlasanWisataScreensState();
}

class _UlasanWisataScreensState extends State<UlasanWisataScreens> {
  bool _tabSudah = true;

  @override
  void initState() {
    super.initState();
    final id = widget.orderId?.replaceAll('#', '');
    if (id == null) return;

    final cocok = _DataUlasan.belum
        .where((p) => p.noPesanan.replaceAll('#', '') == id)
        .firstOrNull;
    if (cocok == null) return;

    _tabSudah = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tulis(cocok);
    });
  }

  Future<void> _tulis(_Pesanan p, {int rating = 0}) =>
      _buka(_FormUlasanScreens(pesanan: p, ratingAwal: rating));

  Future<void> _edit(_Ulasan u) => _buka(_FormUlasanScreens(ulasan: u));

  Future<void> _buka(Widget halaman) async {
    final hasil = await Navigator.push<(_HasilForm, int)>(
      context,
      MaterialPageRoute(builder: (_) => halaman),
    );
    if (hasil == null || !mounted) return;

    setState(() {
      // setelah kirim ulasan, langsung pindah ke tab "Sudah Diulas"
      if (hasil.$1 == _HasilForm.dikirim) _tabSudah = true;
    });

    final pesan = switch (hasil.$1) {
      _HasilForm.dikirim => 'Ulasan terkirim! +${hasil.$2} Poin',
      _HasilForm.disimpan => 'Perubahan ulasan disimpan',
      _HasilForm.dihapus => 'Ulasan dihapus',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: _gaya(12, c: AppColor.putih)),
        backgroundColor: AppColor.ungu,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Ulasan Wisata'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _ringkasan(),
                const SizedBox(height: 12),
                _tabs(),
                const SizedBox(height: 12),
                ..._tabSudah ? _listSudah() : _listBelum(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_outlined,
                        size: 13, color: AppColor.ungu),
                    const SizedBox(width: 6),
                    Text(
                      'Semua ulasan berasal dari tiket pesanan terverifikasi.',
                      style: _gaya(10, c: AppColor.abu),
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

  // ---------------- ringkasan ----------------
  Widget _ringkasan() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _kartu(),
      child: Row(
        children: [
          _stat(
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 17, color: AppColor.kuning),
                const SizedBox(width: 3),
                Text(
                  _DataUlasan.total == 0
                      ? '-'
                      : _DataUlasan.rataRata.toStringAsFixed(1),
                  style: _gaya(16, w: FontWeight.w800),
                ),
              ],
            ),
            'Rata-rata\nRating',
          ),
          _garisV(),
          _stat(
            Text(
              '${_DataUlasan.total}',
              style: _gaya(16, w: FontWeight.w800, c: AppColor.ungu),
            ),
            'Total\nUlasan',
          ),
          _garisV(),
          _stat(
            Text(
              '${_DataUlasan.foto}',
              style: _gaya(16, w: FontWeight.w800, c: AppColor.biru),
            ),
            'Foto\nDiunggah',
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded,
                    size: 18, color: AppColor.kuning),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '+${formatAngka(_DataUlasan.poin)}',
                      style: _gaya(11.5, w: FontWeight.w800),
                    ),
                    Text('Poin', style: _gaya(9, c: AppColor.abu)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(Widget nilai, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nilai,
          const SizedBox(height: 2),
          Text(label, style: _gaya(9, c: AppColor.abu, h: 1.2)),
        ],
      ),
    );
  }

  Widget _garisV() => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColor.abu.withValues(alpha: 0.25),
      );

  // ---------------- tab ----------------
  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab('Sudah Diulas', _DataUlasan.total, true),
          _tab('Belum Diulas', _DataUlasan.belum.length, false),
        ],
      ),
    );
  }

  Widget _tab(String label, int jumlah, bool untukSudah) {
    final pilih = _tabSudah == untukSudah;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabSudah = untukSudah),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: pilih ? AppColor.putih : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: pilih
                ? [
                    BoxShadow(
                      color: AppColor.hitam.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: _gaya(
                  11.5,
                  w: pilih ? FontWeight.w800 : FontWeight.w600,
                  c: pilih
                      ? AppColor.ungu
                      : AppColor.hitam.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: untukSudah
                      ? AppColor.ungu.withValues(alpha: 0.12)
                      : AppColor.kuning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$jumlah',
                  style: _gaya(
                    9.5,
                    w: FontWeight.w800,
                    c: untukSudah ? AppColor.ungu : AppColor.hitam,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- tab: sudah diulas ----------------
  List<Widget> _listSudah() {
    if (_DataUlasan.sudah.isEmpty) {
      return [
        _kosong(
          Icons.rate_review_outlined,
          'Belum ada ulasan',
          'Ulasan yang kamu tulis akan muncul di sini',
        ),
      ];
    }
    return _DataUlasan.sudah.map(_kartuSudah).toList();
  }

  Widget _kartuSudah(_Ulasan u) {
    final n = u.foto.length > 3 ? 3 : u.foto.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _kartu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  u.pesanan.judul,
                  style: _gaya(14, w: FontWeight.w800, h: 1.3),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.ungu.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColor.abu.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 12, color: AppColor.kuning),
                    const SizedBox(width: 3),
                    Text(
                      u.rating.toStringAsFixed(1),
                      style: _gaya(10.5, w: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _chipKategori(u.pesanan.kategori),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  u.pesanan.paket,
                  overflow: TextOverflow.ellipsis,
                  style: _gaya(10,
                      w: FontWeight.w600,
                      c: AppColor.hitam.withValues(alpha: 0.6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            u.teks,
            style: _gaya(12,
                c: AppColor.hitam.withValues(alpha: 0.75), h: 1.5),
          ),
          if (n > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                for (int i = 0; i < n; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _fotoPlaceholder(i, 84)),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.2)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined,
                  size: 13, color: AppColor.ungu),
              const SizedBox(width: 5),
              Text(
                '${u.terbantu} terbantu',
                style: _gaya(10.5, w: FontWeight.w700),
              ),
              Text(
                '  •  ${u.tglUlasan}',
                style: _gaya(10.5, c: AppColor.abu),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _edit(u),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined,
                        size: 13, color: AppColor.ungu),
                    const SizedBox(width: 4),
                    Text(
                      'Edit Ulasan',
                      style: _gaya(10.5, w: FontWeight.w700, c: AppColor.ungu),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- tab: belum diulas ----------------
  List<Widget> _listBelum() {
    if (_DataUlasan.belum.isEmpty) {
      return [
        _kosong(
          Icons.check_circle_outline,
          'Semua tiket sudah diulas',
          'Terima kasih sudah berbagi pengalamanmu',
        ),
      ];
    }
    return _DataUlasan.belum.map(_kartuBelum).toList();
  }

  Widget _kartuBelum(_Pesanan p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: _kartu(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fotoPlaceholder(0, 78, lebar: 78, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _chipKategori(p.kategori),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '• ${p.paket}',
                            overflow: TextOverflow.ellipsis,
                            style: _gaya(9.5,
                                w: FontWeight.w600,
                                c: AppColor.hitam.withValues(alpha: 0.6)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      p.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _gaya(13, w: FontWeight.w800, h: 1.3),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 11, color: AppColor.ungu),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Digunakan pada ${p.tglPakai}',
                            style: _gaya(10, c: AppColor.abu),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 11, color: AppColor.abu),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'No. Pesanan: ${p.noPesanan}',
                            style: _gaya(10, c: AppColor.abu),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.2)),
          const SizedBox(height: 10),
          Row(
            children: [
              // bintang cepat: tap salah satu langsung buka form dengan rating itu
              ...List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => _tulis(p, rating: i + 1),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      Icons.star_outline_rounded,
                      size: 21,
                      color: AppColor.abu.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _tulis(p),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.ungu,
                    foregroundColor: AppColor.putih,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.rate_review_outlined, size: 14),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Tulis Ulasan',
                          overflow: TextOverflow.ellipsis,
                          style: _gaya(11,
                              w: FontWeight.w700, c: AppColor.putih),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColor.putih.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+100 Poin',
                          style: _gaya(8.5,
                              w: FontWeight.w800, c: AppColor.putih),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kosong(IconData icon, String judul, String sub) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      decoration: _kartu(),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColor.abu.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
          Text(judul, style: _gaya(13, w: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(sub, style: _gaya(11, c: AppColor.abu)),
        ],
      ),
    );
  }
}

// ======================= form tulis / edit ulasan =======================
class _FormUlasanScreens extends StatefulWidget {
  final _Pesanan? pesanan; // diisi kalau menulis ulasan baru
  final _Ulasan? ulasan; // diisi kalau mengedit ulasan
  final int ratingAwal;

  const _FormUlasanScreens({
    this.pesanan,
    this.ulasan,
    this.ratingAwal = 0,
  }) : assert(pesanan != null || ulasan != null);

  @override
  State<_FormUlasanScreens> createState() => _FormUlasanScreensState();
}

class _FormUlasanScreensState extends State<_FormUlasanScreens> {
  static const _labelRating = [
    '',
    'Buruk 😞',
    'Kurang Memuaskan 😕',
    'Cukup Baik 🙂',
    'Bagus & Menyenangkan! 😊',
    'Luar Biasa! 😍',
  ];

  bool get _edit => widget.ulasan != null;
  _Pesanan get _p => widget.ulasan?.pesanan ?? widget.pesanan!;

  late int _rating;
  late final Set<String> _aspek;
  late final TextEditingController _ctrl;
  late final List<String> _foto;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.ulasan;
    _rating = u != null ? u.rating.round() : widget.ratingAwal;
    _aspek = u != null ? u.aspek.toSet() : <String>{};
    _ctrl = TextEditingController(text: u?.teks ?? '');
    _foto = List<String>.from(u?.foto ?? const <String>[]);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _info(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(teks, style: _gaya(12, c: AppColor.putih)),
        backgroundColor: AppColor.ungu,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _tambahFoto() {
    if (_foto.length >= 5) {
      _info('Maksimal 5 foto atau video');
      return;
    }
    // TODO: ganti dengan image_picker, sekarang cuma menambah foto contoh
    setState(() => _foto.add('foto_${_foto.length + 1}.jpg'));
  }

  Future<void> _kirim() async {
    final teks = _ctrl.text.trim();

    if (_rating == 0) {
      _info('Pilih bintang dulu ya');
      return;
    }
    if (teks.length < 20) {
      _info('Ceritakan pengalamanmu minimal 20 karakter');
      return;
    }

    setState(() => _loading = true);

    // TODO: panggil API kirim / ubah ulasan
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // urutan aspek mengikuti daftar pilihan
    final aspek = _p.pilihanAspek.where(_aspek.contains).toList();

    if (_edit) {
      _DataUlasan.ubah(
        widget.ulasan!,
        rating: _rating.toDouble(),
        aspek: aspek,
        teks: teks,
        fotoBaru: List<String>.from(_foto),
      );
      Navigator.pop(context, (_HasilForm.disimpan, 0));
    } else {
      final bonus = _foto.isNotEmpty ? 25 : 0;
      _DataUlasan.tambah(
        _Ulasan(
          pesanan: _p,
          rating: _rating.toDouble(),
          aspek: aspek,
          teks: teks,
          foto: List<String>.from(_foto),
          terbantu: 0,
          tglUlasan: _tglHariIni(),
        ),
        bonus,
      );
      Navigator.pop(context, (_HasilForm.dikirim, 100 + bonus));
    }
  }

  Future<void> _hapus() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColor.putih,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColor.kuning.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    size: 26, color: AppColor.kuning),
              ),
              const SizedBox(height: 14),
              Text('Hapus ulasan ini?', style: _gaya(16, w: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'Ulasanmu akan dihapus dan tiket ini kembali ke daftar Belum Diulas.',
                textAlign: TextAlign.center,
                style: _gaya(12, c: AppColor.abu, h: 1.45),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.ungu,
                        side: const BorderSide(color: AppColor.ungu),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Batal',
                          style: _gaya(13, w: FontWeight.w700, c: AppColor.ungu)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.kuning,
                        foregroundColor: AppColor.hitam,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Hapus',
                          style: _gaya(13, w: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ya != true) return;

    // TODO: panggil API hapus ulasan
    _DataUlasan.hapus(widget.ulasan!);
    if (!mounted) return;
    Navigator.pop(context, (_HasilForm.dihapus, 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          SubAppBar(title: _edit ? 'Edit Ulasan' : 'Tulis Ulasan'),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  _infoWisata(),
                  const SizedBox(height: 12),
                  _kartuRating(),
                  const SizedBox(height: 12),
                  _kartuTeks(),
                  const SizedBox(height: 12),
                  _kartuFoto(),
                ],
              ),
            ),
          ),
          _bawah(),
        ],
      ),
    );
  }

  // ---------------- info wisata ----------------
  Widget _infoWisata() {
    final p = _p;
    final u = widget.ulasan;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _kartu(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _fotoPlaceholder(0, 66, lebar: 66, radius: 12),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColor.hitam.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_camera_outlined,
                          size: 10, color: AppColor.putih),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _chipKategori(p.kategori),
                        Text(
                          '• ${p.paket}',
                          style: _gaya(9.5,
                              w: FontWeight.w600,
                              c: AppColor.hitam.withValues(alpha: 0.6)),
                        ),
                        if (_edit)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColor.ungu,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified,
                                    size: 10, color: AppColor.putih),
                                const SizedBox(width: 3),
                                Text(
                                  'Terverifikasi',
                                  style: _gaya(8.5,
                                      w: FontWeight.w700, c: AppColor.putih),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _gaya(13, w: FontWeight.w800, h: 1.3),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _edit
                          ? '${p.noPesanan} • ${p.tglPakai}'
                          : 'No. Pesanan: ${p.noPesanan} • ${p.tglPakai}',
                      style: _gaya(10, c: AppColor.abu),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (u != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColor.ungu.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 13, color: AppColor.abu),
                  const SizedBox(width: 6),
                  Text(
                    'Diulas pertama kali: ${u.tglUlasan}',
                    style: _gaya(10, c: AppColor.abu),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- rating + aspek ----------------
  Widget _kartuRating() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _kartu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'EVALUASI KESELURUHAN',
                  style: _gaya(9, w: FontWeight.w800, c: AppColor.ungu, ls: 0.6),
                ),
              ),
              if (_edit && _rating > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColor.biru.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: AppColor.ungu),
                      const SizedBox(width: 3),
                      Text(
                        'Skor $_rating.0',
                        style: _gaya(9.5, w: FontWeight.w800, c: AppColor.ungu),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                Text(
                  'Bagaimana Pengalamanmu?',
                  style: _gaya(16, w: FontWeight.w800),
                ),
                if (_edit) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Ketuk bintang untuk mengubah penilaian',
                    style: _gaya(10, c: AppColor.abu),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final isi = i < _rating;
                    return GestureDetector(
                      onTap: _loading ? null : () => setState(() => _rating = i + 1),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          isi
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 40,
                          color: isi
                              ? AppColor.kuning
                              : AppColor.abu.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                if (_rating > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColor.ungu.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _labelRating[_rating],
                      style: _gaya(11.5, w: FontWeight.w700, c: AppColor.ungu),
                    ),
                  )
                else
                  Text(
                    'Ketuk bintang untuk menilai',
                    style: _gaya(11, c: AppColor.abu),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _edit ? 'Aspek yang Paling Berkesan:' : 'Apa yang paling kamu sukai?',
            style: _gaya(12, w: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _p.pilihanAspek.map((a) {
              final pilih = _aspek.contains(a);
              return GestureDetector(
                onTap: _loading
                    ? null
                    : () => setState(() {
                          if (pilih) {
                            _aspek.remove(a);
                          } else {
                            _aspek.add(a);
                          }
                        }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: pilih
                        ? AppColor.ungu
                        : AppColor.ungu.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        pilih ? Icons.check : Icons.add,
                        size: 13,
                        color: pilih ? AppColor.putih : AppColor.ungu,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        a,
                        style: _gaya(
                          11,
                          w: FontWeight.w600,
                          c: pilih
                              ? AppColor.putih
                              : AppColor.hitam.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ---------------- teks ulasan ----------------
  Widget _kartuTeks() {
    final n = _ctrl.text.length;
    final ok = _ctrl.text.trim().length >= 20;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _kartu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Ceritakan Pengalamanmu ',
              style: _gaya(13, w: FontWeight.w800),
              children: [
                TextSpan(
                  text: '*',
                  style: _gaya(13, w: FontWeight.w800, c: AppColor.kuning),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            enabled: !_loading,
            minLines: 4,
            maxLines: 6,
            maxLength: 500,
            style: _gaya(12.5, h: 1.5),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Ceritakan pengalamanmu di sini...',
              hintStyle: _gaya(12, c: AppColor.abu),
              filled: true,
              fillColor: AppColor.ungu.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColor.abu.withValues(alpha: 0.3)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColor.abu.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColor.ungu),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                ok ? Icons.check_circle_outline : Icons.info_outline,
                size: 14,
                color: ok ? AppColor.ungu : AppColor.kuning,
              ),
              const SizedBox(width: 5),
              Text(
                ok ? 'Minimal 20 karakter tercapai' : 'Minimal 20 karakter',
                style: _gaya(10, c: AppColor.abu),
              ),
              const Spacer(),
              Text('$n/500', style: _gaya(10, c: AppColor.abu)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- foto / video ----------------
  Widget _kartuFoto() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _kartu(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _edit
                          ? 'Foto atau Video Kunjungan'
                          : 'Tambahkan Foto atau Video',
                      style: _gaya(13, w: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _edit
                          ? '${_foto.length} media terpasang • Maksimal 5 file'
                          : 'Bantu memvisualisasikan pesona tempat ini',
                      style: _gaya(10, c: AppColor.abu),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.biru.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _edit ? '${_foto.length} / 5' : '+25 Poin Bonus',
                  style: _gaya(9.5, w: FontWeight.w800, c: AppColor.ungu),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              const gap = 8.0;
              final lebar = (c.maxWidth - gap * 2) / 3;

              final item = <Widget>[];
              final tile = _tileTambah(lebar);

              if (!_edit && _foto.length < 5) item.add(tile);
              for (int i = 0; i < _foto.length; i++) {
                item.add(_thumb(i, lebar));
              }
              if (_edit && _foto.length < 5) item.add(tile);
              if (_edit) {
                for (int i = _foto.length + 1; i < 5; i++) {
                  item.add(_slotKosong(lebar));
                }
              }

              return Wrap(spacing: gap, runSpacing: gap, children: item);
            },
          ),
        ],
      ),
    );
  }

  Widget _tileTambah(double lebar) {
    return GestureDetector(
      onTap: _loading ? null : _tambahFoto,
      child: Container(
        width: lebar,
        height: lebar,
        decoration: BoxDecoration(
          color: AppColor.ungu.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.ungu.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_a_photo_outlined,
                  size: 18, color: AppColor.ungu),
            ),
            const SizedBox(height: 6),
            Text(
              _edit ? 'Tambah' : 'Unggah',
              style: _gaya(10.5, w: FontWeight.w800, c: AppColor.ungu),
            ),
            if (!_edit) Text('Maks. 5', style: _gaya(9, c: AppColor.abu)),
          ],
        ),
      ),
    );
  }

  Widget _thumb(int i, double lebar) {
    return SizedBox(
      width: lebar,
      height: lebar,
      child: Stack(
        children: [
          _fotoPlaceholder(i, lebar, lebar: lebar, radius: 12),
          Positioned(
            left: 6,
            right: 6,
            bottom: 6,
            child: Text(
              _foto[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _gaya(8, w: FontWeight.w700, c: AppColor.putih),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: _loading ? null : () => setState(() => _foto.removeAt(i)),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColor.hitam.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: AppColor.putih),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotKosong(double lebar) {
    return Container(
      width: lebar,
      height: lebar,
      decoration: BoxDecoration(
        color: AppColor.abu.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 22,
        color: AppColor.abu.withValues(alpha: 0.5),
      ),
    );
  }

  // ---------------- tombol bawah ----------------
  Widget _bawah() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColor.putih,
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _kirim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.ungu,
                  foregroundColor: AppColor.putih,
                  disabledBackgroundColor: AppColor.ungu.withValues(alpha: 0.6),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.putih,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _edit ? Icons.save_outlined : Icons.stars_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _edit ? 'Simpan Perubahan' : 'Kirim Ulasan (+100 Poin)',
                            style: _gaya(13, w: FontWeight.w800, c: AppColor.putih),
                          ),
                        ],
                      ),
              ),
            ),
            if (_edit)
              TextButton.icon(
                onPressed: _loading ? null : _hapus,
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: AppColor.kuning),
                label: Text(
                  'Hapus Ulasan Ini',
                  style: _gaya(12, w: FontWeight.w700, c: AppColor.kuning),
                ),
              ),
          ],
        ),
      ),
    );
  }
}