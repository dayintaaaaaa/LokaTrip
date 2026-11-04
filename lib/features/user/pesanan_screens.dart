import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/pesanan_model.dart';
import '../../widgets/bottom_navigator.dart';
import 'ulasan_wisata_screens.dart';

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

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

class PesananScreens extends StatefulWidget {
  const PesananScreens({super.key});

  @override
  State<PesananScreens> createState() => _PesananScreensState();
}

class _PesananScreensState extends State<PesananScreens> {
  bool _tabAktif = true;
  KategoriPesanan? _filter; // null = semua

  int _hitung(bool aktif, KategoriPesanan? k) => DataPesanan.semua
      .where((p) => p.aktif == aktif && (k == null || p.kategori == k))
      .length;

  List<Pesanan> get _tampil => DataPesanan.semua
      .where((p) =>
          p.aktif == _tabAktif && (_filter == null || p.kategori == _filter))
      .toList();

  Pesanan? get _pesananBaru => DataPesanan.semua
      .where((p) => p.status == StatusPesanan.siapDigunakan)
      .firstOrNull;

  // ---------------- aksi ----------------
  void _info(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(teks, style: _gaya(12, c: AppColor.putih)),
        backgroundColor: AppColor.ungu,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _sheet(Widget Function(BuildContext) isi) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.putih,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(child: SingleChildScrollView(child: isi(ctx))),
    );
  }

  Widget _handle() => Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColor.abu.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _baris(String label, String nilai) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _gaya(11.5, c: AppColor.abu)),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                nilai,
                textAlign: TextAlign.right,
                style: _gaya(11.5, w: FontWeight.w700),
              ),
            ),
          ],
        ),
      );

  void _eTiket(Pesanan p) {
    _sheet(
      (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            Text('E-Tiket', style: _gaya(16, w: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              p.judul,
              textAlign: TextAlign.center,
              style: _gaya(12, c: AppColor.abu),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.putih,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.abu.withValues(alpha: 0.3)),
              ),
              // TODO: ganti dengan QR asli dari backend (mis. package qr_flutter)
              child: const Icon(Icons.qr_code_2, size: 170, color: AppColor.hitam),
            ),
            const SizedBox(height: 10),
            Text(p.id, style: _gaya(13, w: FontWeight.w800, ls: 1)),
            const SizedBox(height: 14),
            _baris(
              'Jadwal',
              p.jam == null ? p.jadwal : '${p.jadwal}, ${p.jam}',
            ),
            _baris('Peserta', p.chips.last),
            _baris('Status', p.labelStatus),
            const SizedBox(height: 10),
            Text(
              'Tunjukkan QR ini di pintu masuk',
              style: _gaya(10.5, c: AppColor.abu),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _btnIsi('Tutup', Icons.close, () => Navigator.pop(ctx)),
            ),
          ],
        ),
      ),
    );
  }

  void _invoice(Pesanan p) {
    _sheet(
      (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _handle()),
            Text('Invoice', style: _gaya(16, w: FontWeight.w800)),
            const SizedBox(height: 12),
            _baris('No. Pesanan', '#${p.id}'),
            _baris('Tanggal Pembelian', p.tglBeli),
            _baris('Produk', p.judul),
            _baris('Jadwal', p.jam == null ? p.jadwal : '${p.jadwal}, ${p.jam}'),
            _baris('Peserta', p.chips.last),
            _baris('Metode Pembayaran', p.metode),
            Divider(color: AppColor.abu.withValues(alpha: 0.3), height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: _gaya(13, w: FontWeight.w800)),
                Text(
                  p.total,
                  style: _gaya(16, w: FontWeight.w800, c: AppColor.ungu),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _btnIsi('Tutup', Icons.close, () => Navigator.pop(ctx)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reschedule(Pesanan p) async {
    final besok = DateTime.now().add(const Duration(days: 1));
    final pilih = await showDatePicker(
      context: context,
      initialDate: besok,
      firstDate: besok,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih tanggal baru',
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColor.ungu,
            onPrimary: AppColor.putih,
            onSurface: AppColor.hitam,
          ),
        ),
        child: child!,
      ),
    );
    if (pilih == null || !mounted) return;
    // TODO: kirim pengajuan reschedule ke backend
    _info(
      'Pengajuan reschedule ke ${pilih.day} ${_bulan[pilih.month - 1]} ${pilih.year} dikirim',
    );
  }

  void _petunjuk(Pesanan p) {
    // TODO: buka Google Maps (package url_launcher)
    _info('Membuka petunjuk arah ke ${p.lokasi}...');
  }

  void _pesanLagi(Pesanan p) {
    // TODO: arahkan ke halaman detail wisata kalau sudah ada
    _info('Membuka ${p.judul}...');
  }

  Future<void> _ulasan(Pesanan p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UlasanWisataScreens(orderId: p.id)),
    );
    if (mounted) setState(() {}); // refresh status ulasan
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    final daftar = _tampil;
    final baru = _pesananBaru;
    final tampilBanner = _tabAktif && baru != null && daftar.contains(baru);

    return Scaffold(
      backgroundColor: AppColor.ungu.withValues(alpha: 0.05),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _tabs(),
            const SizedBox(height: 12),
            _chipFilter(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                children: [
                  if (tampilBanner) _banner(baru),
                  if (daftar.isEmpty)
                    _kosong()
                  else
                    ...daftar.map(
                      (p) => p.aktif ? _kartuAktif(p) : _kartuSelesai(p),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigator(currentIndex: 2),
    );
  }

  // ---------------- header, tab, filter ----------------
  Widget _header() {
    return Container(
      color: AppColor.putih,
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, size: 22, color: AppColor.hitam),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pesanan Saya', style: _gaya(16, w: FontWeight.w800)),
                if (!_tabAktif)
                  Text(
                    '${_hitung(false, null)} Tiket Selesai Dikunjungi',
                    style: _gaya(10.5, c: AppColor.abu),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab('Pesanan Aktif', _hitung(true, null), true),
          _tab('Riwayat Selesai', _hitung(false, null), false),
        ],
      ),
    );
  }

  Widget _tab(String label, int jumlah, bool untukAktif) {
    final pilih = _tabAktif == untukAktif;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tabAktif = untukAktif;
          _filter = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
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
                  c: pilih ? AppColor.hitam : AppColor.abu,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: pilih
                      ? AppColor.ungu
                      : AppColor.abu.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$jumlah',
                  style: _gaya(
                    9.5,
                    w: FontWeight.w800,
                    c: pilih ? AppColor.putih : AppColor.hitam,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipFilter() {
    final item = <(KategoriPesanan?, String, IconData)>[
      (null, 'Semua', Icons.grid_view_rounded),
      (KategoriPesanan.tiketWisata, 'Tiket Wisata',
          Icons.confirmation_number_outlined),
      (KategoriPesanan.tur, 'Tur & Open Trip', Icons.flag_outlined),
    ];

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: item.map((e) {
          final aktif = _filter == e.$1;
          final n = _hitung(_tabAktif, e.$1);
          return GestureDetector(
            onTap: () => setState(() => _filter = e.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: aktif ? AppColor.ungu : AppColor.putih,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: aktif
                      ? AppColor.ungu
                      : AppColor.abu.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    e.$3,
                    size: 14,
                    color: aktif ? AppColor.putih : AppColor.ungu,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${e.$2} ($n)',
                    style: _gaya(
                      11,
                      w: FontWeight.w700,
                      c: aktif ? AppColor.putih : AppColor.hitam,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- banner pembayaran ----------------
  Widget _banner(Pesanan p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.kuning.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.kuning.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColor.kuning.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                size: 18, color: AppColor.hitam),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PEMBAYARAN BERHASIL!',
                        style: _gaya(10, w: FontWeight.w800, ls: 0.3),
                      ),
                    ),
                    Text('Baru saja', style: _gaya(9.5, c: AppColor.abu)),
                  ],
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    style: _gaya(11.5, h: 1.4),
                    children: [
                      const TextSpan(text: 'Tiket '),
                      TextSpan(
                        text: p.judul.split(' - ').first,
                        style: _gaya(11.5, w: FontWeight.w800, c: AppColor.ungu),
                      ),
                      const TextSpan(
                        text:
                            ' sudah terbit dan siap digunakan langsung di pintu masuk.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _eTiket(p),
                  child: Text(
                    'Buka Sekarang →',
                    style: _gaya(11, w: FontWeight.w800, c: AppColor.ungu),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- kartu pesanan aktif ----------------
  Widget _kartuAktif(Pesanan p) {
    final tur = p.kategori == KategoriPesanan.tur;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _kartu(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Icon(
                  tur
                      ? Icons.flag_outlined
                      : Icons.confirmation_number_outlined,
                  size: 15,
                  color: AppColor.ungu,
                ),
                const SizedBox(width: 6),
                Text('#${p.id}', style: _gaya(11.5, w: FontWeight.w800)),
                Flexible(
                  child: Text(
                    '  •  ${p.tglBeli}',
                    style: _gaya(10, c: AppColor.abu),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                _statusChip(p),
              ],
            ),
          ),
          _garis(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Foto(label: p.labelFoto, height: 84, width: 76, radius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.judul,
                        style: _gaya(14, w: FontWeight.w800, h: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _lokasi(p.lokasi),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _pill(p.chips.first, tint: true),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              p.chips.last,
                              style: _gaya(10.5, c: AppColor.abu),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _jadwalTotal(p),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: _btnOutline(
                    tur ? 'Bisa Reschedule' : 'Petunjuk Arah',
                    tur ? Icons.event_repeat_outlined : Icons.near_me_outlined,
                    () => tur ? _reschedule(p) : _petunjuk(p),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _btnIsi(
                    'Lihat E-Tiket',
                    Icons.qr_code_2,
                    () => _eTiket(p),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- kartu riwayat selesai ----------------
  Widget _kartuSelesai(Pesanan p) {
    final bisaBeriUlasan = p.bisaUlas && p.rating == null;
    final sudahUlas = p.rating != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _kartu(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER ID',
                        style: _gaya(8.5,
                            w: FontWeight.w800, c: AppColor.abu, ls: 0.5),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            p.kategori == KategoriPesanan.tur
                                ? Icons.flag_outlined
                                : Icons.confirmation_number_outlined,
                            size: 14,
                            color: AppColor.ungu,
                          ),
                          const SizedBox(width: 5),
                          Text('#${p.id}',
                              style: _gaya(12, w: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Dibeli ${p.tglBeli}',
                          style: _gaya(10, c: AppColor.abu)),
                    ],
                  ),
                ),
                _statusChip(p),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _Foto(
              label: p.labelFoto,
              height: 140,
              radius: 12,
              labelKanan: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.judul, style: _gaya(15, w: FontWeight.w800, h: 1.3)),
                const SizedBox(height: 4),
                _lokasi(p.lokasi),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: p.chips.map((c) => _pill(c)).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _jadwalTotal(p),
          ),

          // ajakan memberi ulasan
          if (bisaBeriUlasan)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.kuning.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColor.kuning.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded,
                            size: 16, color: AppColor.hitam),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bagikan pengalamanmu!',
                                style: _gaya(11.5, w: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(
                              'Dapatkan 500 Poin Lokatrip dengan memberi rating & ulasan.',
                              style: _gaya(10.5, c: AppColor.abu, h: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: _btnIsi(
                      'Beri Ulasan',
                      Icons.star_rounded,
                      () => _ulasan(p),
                    ),
                  ),
                ],
              ),
            ),

          // rating yang sudah diberikan
          if (sudahUlas)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  _bintang(p.rating!),
                  const SizedBox(width: 6),
                  Text(p.rating!.toStringAsFixed(1),
                      style: _gaya(11.5, w: FontWeight.w800)),
                  const SizedBox(width: 4),
                  Text('(Sudah Diulas)',
                      style: _gaya(10, c: AppColor.abu)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _ulasan(p),
                    child: Text(
                      'Edit Ulasan',
                      style: _gaya(11, w: FontWeight.w700, c: AppColor.ungu),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          _garis(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _invoice(p),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 15,
                            color: AppColor.hitam.withValues(alpha: 0.6)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            // contoh aturan dummy: tiket yang belum diulas masih punya E-Tiket
                            bisaBeriUlasan
                                ? 'Lihat Invoice / E-Tiket'
                                : 'Lihat Invoice',
                            style: _gaya(11,
                                w: FontWeight.w600,
                                c: AppColor.hitam.withValues(alpha: 0.7)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _btnOutline('Pesan Lagi', Icons.refresh, () => _pesanLagi(p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- potongan kecil ----------------
  Widget _jadwalTotal(Pesanan p) {
    final huruf = !p.aktif;
    String t(String s) => huruf ? s.toUpperCase() : s;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t(p.labelJadwal),
                  style: _gaya(9, c: AppColor.abu, w: FontWeight.w700)),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColor.ungu),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      huruf ? '${p.jadwal} (Selesai)' : p.jadwal,
                      style: _gaya(11.5, w: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              if (p.jam != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(p.jam!, style: _gaya(10, c: AppColor.abu)),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(t(p.labelTotal),
                style: _gaya(9, c: AppColor.abu, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(p.total,
                style: _gaya(17, w: FontWeight.w800, c: AppColor.ungu)),
            if (p.catatanTotal != null)
              Text(p.catatanTotal!,
                  style: _gaya(9.5, w: FontWeight.w700, c: AppColor.abu)),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(Pesanan p) {
    final (bg, fg, ic) = switch (p.status) {
      StatusPesanan.siapDigunakan => (
          AppColor.kuning.withValues(alpha: 0.3),
          AppColor.hitam,
          Icons.bolt,
        ),
      StatusPesanan.terkonfirmasi => (
          AppColor.biru.withValues(alpha: 0.25),
          AppColor.hitam,
          Icons.check_circle_outline,
        ),
      StatusPesanan.selesai => (
          AppColor.ungu.withValues(alpha: 0.1),
          AppColor.ungu,
          Icons.verified_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(p.labelStatus,
              style: _gaya(9, w: FontWeight.w800, c: fg)),
        ],
      ),
    );
  }

  Widget _pill(String teks, {bool tint = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tint
            ? AppColor.ungu.withValues(alpha: 0.1)
            : AppColor.abu.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        teks,
        style: _gaya(
          10,
          w: FontWeight.w600,
          c: tint ? AppColor.ungu : AppColor.hitam.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _lokasi(String teks) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 12, color: AppColor.ungu),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            teks,
            style: _gaya(10.5, c: AppColor.abu),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _bintang(double r) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < r.round() ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: AppColor.kuning,
        ),
      ),
    );
  }

  Widget _garis() =>
      Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.2));

  BoxDecoration _kartu() => BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Widget _btnOutline(String teks, IconData ic, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(ic, size: 15),
      label: Text(teks,
          style: _gaya(11, w: FontWeight.w700, c: AppColor.ungu)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColor.ungu,
        side: BorderSide(color: AppColor.ungu.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _btnIsi(String teks, IconData ic, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(ic, size: 15),
      label: Text(teks,
          style: _gaya(11, w: FontWeight.w700, c: AppColor.putih)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.ungu,
        foregroundColor: AppColor.putih,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _kosong() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: _kartu(),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 36, color: AppColor.abu.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
          Text('Belum ada pesanan', style: _gaya(13, w: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('Pesanan di kategori ini akan muncul di sini',
              style: _gaya(11, c: AppColor.abu)),
        ],
      ),
    );
  }
}

// foto placeholder, TODO: ganti dengan Image.asset / Image.network dari backend
class _Foto extends StatelessWidget {
  final String label;
  final double height;
  final double? width;
  final double radius;
  final bool labelKanan;

  const _Foto({
    required this.label,
    required this.height,
    this.width,
    required this.radius,
    this.labelKanan = false,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.hitam.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: _gaya(8.5, w: FontWeight.w700, c: AppColor.putih)),
    );

    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColor.biru, AppColor.ungu],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.landscape_outlined,
              size: height > 100 ? 36 : 22,
              color: AppColor.putih.withValues(alpha: 0.6),
            ),
          ),
          if (labelKanan)
            Positioned(right: 8, bottom: 8, child: chip)
          else
            Positioned(left: 0, right: 0, bottom: 5, child: Center(child: chip)),
        ],
      ),
    );
  }
}