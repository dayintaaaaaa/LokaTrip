import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/pesanan_model.dart';
import '../../widgets/bottom_navigator.dart';
import 'ulasan_wisata_screens.dart';
import '../../services/pesanan_service.dart';
import '../../services/maps_service.dart';
import '../../widgets/qr_palsu.dart';
import 'home_screens.dart';

TextStyle _gaya(
  double size, {
  FontWeight w = FontWeight.w500,
  Color c = AppColor.hitam,
  double? h,
  double? ls,
}) => GoogleFonts.manrope(
  fontSize: size,
  fontWeight: w,
  color: c,
  height: h,
  letterSpacing: ls,
);

class PesananScreens extends StatefulWidget {
  final bool mulaiDiRiwayat; // true = buka tab Riwayat Selesai
  const PesananScreens({super.key, this.mulaiDiRiwayat = false});

  @override
  State<PesananScreens> createState() => _PesananScreensState();
}

class _PesananScreensState extends State<PesananScreens> {
  bool _tabAktif = true;
  String? _filter; // null = semua kategori
  final _service = PesananService();
  List<Pesanan> _semua = [];
  List<String> _semuaKategori = [];
  bool _memuat = true;
  String? _error;
  final Set<int> _pesananMemproses = {};

  @override
  void initState() {
    super.initState();
    _tabAktif = !widget.mulaiDiRiwayat;
    _muat();
  }

  Future<void> _muat({bool tampilLoading = true}) async {
    if (tampilLoading) setState(() => _memuat = true);
    try {
      final hasil = await _service.ambilSemua();
      final kategori = await _service.ambilKategoriWisata();
      if (!mounted) return;
      setState(() {
        _semua = hasil;
        _semuaKategori = kategori;
        _error = null;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _memuat = false;
      });
    }
  }

  int _hitung(bool aktif, [String? kategori]) => _semua
      .where(
        (p) =>
            p.aktif == aktif &&
            (kategori == null || p.kategoriWisata == kategori),
      )
      .length;

  List<String> get _kategoriTersedia =>
      {..._semuaKategori, ..._semua.map((p) => p.kategoriWisata)}.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  List<Pesanan> get _tampil => _semua
      .where(
        (p) =>
            p.aktif == _tabAktif &&
            (_filter == null || p.kategoriWisata == _filter),
      )
      .toList();

  // banner hanya untuk pesanan siap pakai yang baru dibuat (< 10 menit)
  Pesanan? get _pesananBaru => _semua
      .where(
        (p) =>
            p.status == StatusPesanan.siapDigunakan &&
            p.dibuat != null &&
            DateTime.now().difference(p.dibuat!).inMinutes < 10,
      )
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            Text('E-Tiket Wisata', style: _gaya(16, w: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(
              p.status == StatusPesanan.kadaluarsa
                  ? 'Tiket ini sudah tidak berlaku karena tanggal kunjungan telah lewat'
                  : 'Tunjukkan tiket ini kepada petugas di pintu masuk',
              textAlign: TextAlign.center,
              style: _gaya(10.5, c: AppColor.abu),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColor.putih,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.hitam.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.ungu, AppColor.biru],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _chipETiket(
                              p.status == StatusPesanan.selesai
                                  ? 'TELAH DIKUNJUNGI'
                                  : p.status == StatusPesanan.kadaluarsa
                                  ? 'TIKET KADALUARSA'
                                  : 'TIKET AKTIF',
                              p.status == StatusPesanan.kadaluarsa
                                  ? const Color(0xFFF1F5F9)
                                  : AppColor.kuning.withValues(alpha: 0.2),
                              p.status == StatusPesanan.kadaluarsa
                                  ? const Color(0xFF64748B)
                                  : AppColor.kuning,
                              titik: true,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: _chipETiket(
                                p.kategori == KategoriPesanan.tur
                                    ? 'TUR & OPEN TRIP'
                                    : 'TIKET WISATA',
                                AppColor.biru.withValues(alpha: 0.2),
                                AppColor.ungu,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: p.id));
                                _info('Kode pesanan disalin');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 15,
                                  color: AppColor.ungu,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColor.ungu,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                p.lokasi,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _gaya(
                                  10,
                                  w: FontWeight.w700,
                                  c: AppColor.ungu,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.judul,
                          style: _gaya(15, w: FontWeight.w800, h: 1.25),
                        ),
                        const SizedBox(height: 4),
                        Text(p.chips.first, style: _gaya(10, c: AppColor.abu)),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: AppColor.abu.withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _kolomETiket(
                                'TANGGAL KUNJUNGAN',
                                Icons.calendar_today_outlined,
                                p.jadwal,
                                p.jam ?? p.labelJadwal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _kolomETiket(
                                'JUMLAH PENGUNJUNG',
                                Icons.people_outline,
                                p.chips.last,
                                p.labelStatus,
                                subWarna: AppColor.ungu,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              size: 13,
                              color: AppColor.abu,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'LOKASI',
                              style: _gaya(
                                8,
                                w: FontWeight.w800,
                                c: AppColor.abu,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.lokasi,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _gaya(9, w: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _sobekanETiket(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.putih,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.hitam.withValues(alpha: 0.08),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              QrPalsu(
                                seed: p.id,
                                ukuran: 150,
                                warna: AppColor.ungu,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'KODE PESANAN: ${p.id}',
                                textAlign: TextAlign.center,
                                style: _gaya(
                                  8,
                                  w: FontWeight.w800,
                                  c: AppColor.abu,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.status == StatusPesanan.kadaluarsa
                              ? 'QR ini sudah tidak berlaku karena tanggal kunjungan telah lewat'
                              : 'Tunjukkan QR code ini kepada petugas saat masuk',
                          textAlign: TextAlign.center,
                          style: _gaya(
                            10,
                            c: AppColor.hitam.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.biru.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.wb_sunny_outlined,
                                size: 12,
                                color: AppColor.kuning,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Atur kecerahan layar maksimal saat memindai',
                                  style: _gaya(
                                    9,
                                    w: FontWeight.w600,
                                    c: AppColor.ungu,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipETiket(String teks, Color bg, Color fg, {bool titik = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titik) ...[
              Icon(Icons.circle, size: 6, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              teks,
              style: _gaya(8, w: FontWeight.w800, c: fg),
            ),
          ],
        ),
      );

  Widget _kolomETiket(
    String label,
    IconData ikon,
    String nilai,
    String sub, {
    Color subWarna = AppColor.abu,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: _gaya(8, w: FontWeight.w800, c: AppColor.abu),
      ),
      const SizedBox(height: 4),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 12, color: AppColor.ungu),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              nilai,
              style: _gaya(10, w: FontWeight.w800),
              maxLines: 2,
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16, top: 2),
        child: Text(sub, style: _gaya(9, c: subWarna)),
      ),
    ],
  );

  Widget _sobekanETiket() => Row(
    children: [
      Container(
        width: 10,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColor.ungu,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
        ),
      ),
      Expanded(
        child: LayoutBuilder(
          builder: (_, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              (constraints.maxWidth / 8).floor(),
              (_) => Container(
                width: 4,
                height: 1.5,
                color: AppColor.abu.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
      Container(
        width: 10,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColor.ungu,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
        ),
      ),
    ],
  );

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
            _baris(
              'Jadwal',
              p.jam == null ? p.jadwal : '${p.jadwal}, ${p.jam}',
            ),
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

  Future<void> _petunjuk(Pesanan p) async {
    final tujuan = [
      p.judul,
      p.lokasi,
    ].where((bagian) => bagian.trim().isNotEmpty).join(', ');
    final berhasil = await bukaGoogleMaps(tujuan, petunjukArah: true);
    if (!mounted || berhasil) return;
    _info('Petunjuk arah belum bisa dibuka. Coba lagi sebentar.');
  }

  Future<void> _ulasan(Pesanan p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UlasanWisataScreens(orderId: p.orderId.toString()),
      ),
    );
    if (mounted) _muat(tampilLoading: false); // refresh status ulasan
  }

  Future<void> _tandaiSelesai(Pesanan p) async {
    if (_pesananMemproses.contains(p.idPemesanan)) return;
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Tandai pesanan selesai?',
          style: _gaya(15, w: FontWeight.w800),
        ),
        content: Text('Tandai pesanan ini sebagai selesai?', style: _gaya(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: _gaya(12, c: AppColor.abu)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Ya, Selesai',
              style: _gaya(12, w: FontWeight.w800, c: AppColor.ungu),
            ),
          ),
        ],
      ),
    );
    if (setuju != true ||
        !mounted ||
        _pesananMemproses.contains(p.idPemesanan)) {
      return;
    }
    setState(() => _pesananMemproses.add(p.idPemesanan));
    try {
      await _service.tandaiSelesai(p.idPemesanan);
      if (!mounted) return;
      setState(() {
        final index = _semua.indexWhere(
          (pesanan) => pesanan.idPemesanan == p.idPemesanan,
        );
        if (index != -1) {
          _semua[index] = _semua[index].copyWithStatus(
            StatusPesanan.selesai,
            'Selesai',
          );
        }
      });
      _info('Pesanan ditandai selesai');
    } on PesananGagal catch (e) {
      if (mounted) _info(e.pesan);
    } catch (e) {
      debugPrint('Tandai pesanan selesai gagal: $e');
      if (mounted) {
        _info('Gagal menandai pesanan selesai. Coba lagi nanti.');
      }
    } finally {
      if (mounted) setState(() => _pesananMemproses.remove(p.idPemesanan));
    }
  }

  // ---------------- build ----------------
  @override
  Widget build(BuildContext context) {
    final daftar = _tampil;
    final baru = _pesananBaru;
    final tampilBanner = _tabAktif && baru != null && daftar.contains(baru);

    return Scaffold(
      backgroundColor: AppColor.putih,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _tabs(),
            if (!_tabAktif)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 15,
                      color: AppColor.ungu,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Pesanan yang sudah dibayar masuk ke riwayat setelah tanggal kunjungan lewat.',
                        style: _gaya(10.5, c: AppColor.abu, h: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            _chipFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _muat(tampilLoading: false),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    if (_memuat)
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      _gagal()
                    else ...[
                      if (tampilBanner) _banner(baru),
                      if (daftar.isEmpty)
                        _kosong()
                      else
                        ...daftar.map(
                          (p) => p.aktif ? _kartuAktif(p) : _kartuSelesai(p),
                        ),
                    ],
                  ],
                ),
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
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreens()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back, size: 22, color: AppColor.hitam),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pesanan Saya', style: _gaya(16, w: FontWeight.w800)),
                if (!_tabAktif)
                  Text(
                    '${_hitung(false, null)} Pesanan di Riwayat',
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
    final item = <(String?, String, IconData)>[
      (null, 'Semua', Icons.grid_view_rounded),
      for (final kategori in _kategoriTersedia)
        (kategori, kategori, _ikonKategori(kategori)),
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

  IconData _ikonKategori(String namaKategori) {
    final nama = namaKategori.toLowerCase();
    if (nama.contains('tur') || nama.contains('open trip')) {
      return Icons.flag_outlined;
    }
    if (nama.contains('water') || nama.contains('kolam')) {
      return Icons.pool_outlined;
    }
    if (nama.contains('candi') || nama.contains('budaya')) {
      return Icons.account_balance_outlined;
    }
    if (nama.contains('playground')) return Icons.toys_outlined;
    if (nama.contains('spa')) return Icons.spa_outlined;
    if (nama.contains('alam') || nama.contains('outbound')) {
      return Icons.landscape_outlined;
    }
    if (nama.contains('atraksi') || nama.contains('rekreasi')) {
      return Icons.attractions_outlined;
    }
    return Icons.confirmation_number_outlined;
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
            child: const Icon(
              Icons.check_circle_outline,
              size: 18,
              color: AppColor.hitam,
            ),
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
                        style: _gaya(
                          11.5,
                          w: FontWeight.w800,
                          c: AppColor.ungu,
                        ),
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
    final bisaTandaiSelesai =
        p.status == StatusPesanan.siapDigunakan && p.kunjunganHariIniWib;

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
                _Foto(
                  label: p.labelFoto,
                  path: p.fotoUrl,
                  height: 84,
                  width: 76,
                  radius: 12,
                ),
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
            child: Column(
              children: [
                if (p.status == StatusPesanan.kadaluarsa)
                  SizedBox(
                    width: double.infinity,
                    child: _btnIsi(
                      'Lihat E-Tiket',
                      Icons.qr_code_2,
                      () => _eTiket(p),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _btnOutline(
                          'Petunjuk Arah',
                          Icons.near_me_outlined,
                          () => _petunjuk(p),
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
                if (bisaTandaiSelesai) ...[
                  const SizedBox(height: 9),
                  SizedBox(
                    width: double.infinity,
                    child: _btnOutline(
                      'Tandai Selesai',
                      Icons.check_circle_outline,
                      () => _tandaiSelesai(p),
                      memuat: _pesananMemproses.contains(p.idPemesanan),
                    ),
                  ),
                ],
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
                        style: _gaya(
                          8.5,
                          w: FontWeight.w800,
                          c: AppColor.abu,
                          ls: 0.5,
                        ),
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
                          Text(
                            '#${p.id}',
                            style: _gaya(12, w: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dibeli ${p.tglBeli}',
                        style: _gaya(10, c: AppColor.abu),
                      ),
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
              path: p.fotoUrl,
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
                        child: const Icon(
                          Icons.stars_rounded,
                          size: 16,
                          color: AppColor.hitam,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bagikan pengalamanmu!',
                              style: _gaya(11.5, w: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bagikan pengalamanmu lewat rating dan ulasan.',
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
                  Text(
                    p.rating!.toStringAsFixed(1),
                    style: _gaya(11.5, w: FontWeight.w800),
                  ),
                  const SizedBox(width: 4),
                  Text('(Sudah Diulas)', style: _gaya(10, c: AppColor.abu)),
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
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 15,
                          color: AppColor.hitam.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            bisaBeriUlasan
                                ? 'Lihat Invoice / E-Tiket'
                                : 'Lihat Invoice',
                            style: _gaya(
                              11,
                              w: FontWeight.w600,
                              c: AppColor.hitam.withValues(alpha: 0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _btnOutline(
                  'Lihat E-Tiket',
                  Icons.qr_code_2,
                  () => _eTiket(p),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- elemen tambahan ----------------
  Widget _jadwalTotal(Pesanan p) {
    final huruf = p.status == StatusPesanan.kadaluarsa ||
        p.status == StatusPesanan.selesai;
    String t(String s) => huruf ? s.toUpperCase() : s;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(p.labelJadwal),
                style: _gaya(9, c: AppColor.abu, w: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: AppColor.ungu,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      huruf
                          ? '${p.jadwal} (${p.status == StatusPesanan.kadaluarsa ? 'Kadaluarsa' : 'Selesai'})'
                          : p.jadwal,
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
            Text(
              t(p.labelTotal),
              style: _gaya(9, c: AppColor.abu, w: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              p.total,
              style: _gaya(17, w: FontWeight.w800, c: AppColor.ungu),
            ),
            if (p.catatanTotal != null)
              Text(
                p.catatanTotal!,
                style: _gaya(9.5, w: FontWeight.w700, c: AppColor.abu),
              ),
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
      StatusPesanan.kadaluarsa => (
        const Color(0xFFF1F5F9),
        const Color(0xFF64748B),
        Icons.event_busy_outlined,
      ),
      StatusPesanan.selesai => (
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
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
          Text(
            p.labelStatus,
            style: _gaya(9, w: FontWeight.w800, c: fg),
          ),
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

  Widget _btnOutline(
    String teks,
    IconData ic,
    VoidCallback onTap, {
    bool memuat = false,
  }) {
    return OutlinedButton.icon(
      onPressed: memuat ? null : onTap,
      icon: memuat
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(ic, size: 15),
      label: Text(
        teks,
        style: _gaya(11, w: FontWeight.w700, c: AppColor.ungu),
      ),
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
      label: Text(
        teks,
        style: _gaya(11, w: FontWeight.w700, c: AppColor.putih),
      ),
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
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: AppColor.abu.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          Text('Belum ada pesanan', style: _gaya(13, w: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            'Pesanan di kategori ini akan muncul di sini',
            style: _gaya(11, c: AppColor.abu),
          ),
        ],
      ),
    );
  }

  Widget _gagal() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: _kartu(),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 36,
            color: AppColor.abu.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          Text('Gagal memuat pesanan', style: _gaya(13, w: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: _gaya(11, c: AppColor.abu),
          ),
          const SizedBox(height: 14),
          _btnIsi('Coba Lagi', Icons.refresh, _muat),
        ],
      ),
    );
  }
}

// Thumbnail wisata; tetap menampilkan placeholder bila foto belum tersedia.
class _Foto extends StatelessWidget {
  final String label;
  final String? path;
  final double height;
  final double? width;
  final double radius;
  final bool labelKanan;

  const _Foto({
    required this.label,
    this.path,
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
      child: Text(
        label,
        style: _gaya(8.5, w: FontWeight.w700, c: AppColor.putih),
      ),
    );

    final placeholder = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.biru, AppColor.ungu],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.landscape_outlined,
        size: height > 100 ? 36 : 22,
        color: AppColor.putih.withValues(alpha: 0.6),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: path == null || path!.trim().isEmpty
                  ? placeholder
                  : Image.network(
                      path!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : placeholder,
                      errorBuilder: (_, _, _) => placeholder,
                    ),
            ),
            if (labelKanan)
              Positioned(right: 8, bottom: 8, child: chip)
            else
              Positioned(
                left: 0,
                right: 0,
                bottom: 5,
                child: Center(child: chip),
              ),
          ],
        ),
      ),
    );
  }
}
