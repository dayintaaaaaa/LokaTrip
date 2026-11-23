import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format_rupiah.dart';
import '../../core/format_tanggal.dart';
import '../../models/data_pemesanan.dart';
import '../../models/detail_wisata.dart';
import '../../models/ketersediaan_dummy.dart';
import '../../services/pemesanan_service.dart';
import 'atur_jadwal_widgets/jumlah_pengunjung.dart';
import 'atur_jadwal_widgets/kalender_kunjungan.dart';
import 'atur_jadwal_widgets/ringkasan_wisata.dart';
import 'checkout_screens.dart';

// Langkah pertama pemesanan: pilih tanggal kunjungan dan jumlah pengunjung.
//
// Wisata dari Supabase (PaketTiket.idPaket terisi) memakai sisa kuota asli
// dari tabel kuota_harian. Wisata dummy (idPaket null) tetap memakai
// KetersediaanDummy supaya halaman yang belum disambungkan tidak rusak.
class AturJadwalScreens extends StatefulWidget {
  final DetailWisata detail;
  final GrupTiket grup; // grup tiket yang dipilih di halaman detail
  final PaketTiket paket;

  const AturJadwalScreens({
    super.key,
    required this.detail,
    required this.grup,
    required this.paket,
  });

  @override
  State<AturJadwalScreens> createState() => _AturJadwalScreensState();
}

class _AturJadwalScreensState extends State<AturJadwalScreens> {
  static const _latar = Color(0xFFF5F6FA);

  // kuota di database tersedia 60 hari: hari ini + 59 hari
  static const _hariKuota = 59;

  final _service = PemesananService();

  late final DateTime _awal; // hari ini
  late final DateTime _akhir; // batas akhir kalender
  late DateTime _bulan; // bulan yang tampil di kalender
  late DateTime _tanggal; // tanggal terpilih
  int _dewasa = 1;
  int _anak = 0;
  int _bayi = 0;

  Map<DateTime, int> _kuota = {}; // tanggal -> sisa kuota (data asli)
  bool _memuat = false;
  String? _errorMuat;

  // wisata dari Supabase punya idPaket, wisata dummy tidak
  bool get _nyata => widget.paket.idPaket != null;

  Ketersediaan _info(DateTime t) {
    if (!_nyata) return KetersediaanDummy.untuk(t, widget.paket.harga);
    // tanggal yang tidak ada di tabel kuota dianggap belum tersedia
    final sisa = _kuota[DateTime(t.year, t.month, t.day)] ?? 0;
    return Ketersediaan(harga: widget.paket.harga, kuota: sisa);
  }

  int get _hargaDewasa => _info(_tanggal).harga;
  int get _hargaAnak => _nyata
      ? (widget.paket.hargaAnak ?? 0)
      : KetersediaanDummy.hargaAnak(_hargaDewasa);
  int get _tiket => _dewasa + _anak; // bayi tidak dihitung
  int get _total => _dewasa * _hargaDewasa + _anak * _hargaAnak;

  // batas tiket = batas per transaksi, atau sisa kuota kalau lebih kecil
  int get _maksTiket => math.min(
    KetersediaanDummy.maksTiketPerTransaksi,
    _info(_tanggal).kuota,
  );

  bool get _bisaLanjut =>
      !_memuat && _errorMuat == null && !_info(_tanggal).penuh;

  @override
  void initState() {
    super.initState();
    final sekarang = DateTime.now();
    _awal = DateTime(sekarang.year, sekarang.month, sekarang.day);
    _akhir = _nyata
        ? DateTime(_awal.year, _awal.month, _awal.day + _hariKuota)
        : DateTime(_awal.year + 1, _awal.month, _awal.day);
    // data asli: tanggal pertama dicari setelah kuota selesai dimuat
    _tanggal = _nyata
        ? DateTime(_awal.year, _awal.month, _awal.day + 1)
        : _tanggalPertamaTersedia();
    _bulan = DateTime(_tanggal.year, _tanggal.month);
    _muat();
  }

  // ambil sisa kuota per tanggal dari Supabase
  Future<void> _muat() async {
    if (!_nyata) return;
    setState(() {
      _memuat = true;
      _errorMuat = null;
    });
    try {
      final data = await _service.sisaKuota(
        widget.paket.idPaket!,
        dari: _awal,
        sampai: _akhir,
      );
      if (!mounted) return;
      setState(() {
        _kuota = data;
        _tanggal = _tanggalPertamaTersedia();
        _bulan = DateTime(_tanggal.year, _tanggal.month);
        _sesuaikanJumlah();
        _memuat = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat kuota: $e');
      if (!mounted) return;
      setState(() {
        _errorMuat = 'Gagal memuat jadwal. Periksa koneksi internetmu.';
        _memuat = false;
      });
    }
  }

  // mulai dari besok, cari tanggal pertama yang kuotanya masih ada
  DateTime _tanggalPertamaTersedia() {
    var t = DateTime(_awal.year, _awal.month, _awal.day + 1);
    for (var i = 0; i < 60; i++) {
      if (!_info(t).penuh) return t;
      t = DateTime(t.year, t.month, t.day + 1);
    }
    return DateTime(_awal.year, _awal.month, _awal.day + 1);
  }

  void _pilihTanggal(DateTime t) {
    setState(() {
      _tanggal = t;
      _sesuaikanJumlah();
    });
  }

  // kuota tanggal baru bisa lebih kecil dari jumlah yang sudah dipilih
  void _sesuaikanJumlah() {
    final maks = _maksTiket;
    while (_dewasa + _anak > maks && (_anak > 0 || _dewasa > 1)) {
      if (_anak > 0) {
        _anak--;
      } else {
        _dewasa--;
      }
    }
    if (_bayi > _dewasa) _bayi = _dewasa;
  }

  void _gantiBulan(int arah) {
    setState(() => _bulan = DateTime(_bulan.year, _bulan.month + arah));
  }

  void _ubahDewasa(int d) {
    setState(() {
      _dewasa += d;
      if (_bayi > _dewasa) _bayi = _dewasa; // 1 wali per bayi
    });
  }

  void _ubahAnak(int d) => setState(() => _anak += d);
  void _ubahBayi(int d) => setState(() => _bayi += d);

  void _lanjut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreens(
          pesanan: DataPemesanan(
            detail: widget.detail,
            grup: widget.grup,
            paket: widget.paket,
            tanggal: _tanggal,
            dewasa: _dewasa,
            anak: _anak,
            bayi: _bayi,
            hargaDewasa: _hargaDewasa,
            hargaAnak: _hargaAnak,
          ),
        ),
      ),
    );
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
              child: _memuat
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMuat != null
                  ? _galatMuat()
                  : _isi(),
            ),
          ],
        ),
        bottomNavigationBar: _barTotal(),
      ),
    );
  }

  // isi halaman: ringkasan, kalender, jumlah pengunjung
  Widget _isi() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        RingkasanWisata(
          judul: widget.detail.judul,
          lokasi: widget.detail.lokasi,
          gambar: widget.detail.gambar,
        ),
        const SizedBox(height: 14),
        KalenderKunjungan(
          bulan: _bulan,
          terpilih: _tanggal,
          awal: _awal,
          akhir: _akhir,
          ketersediaan: _info,
          onPilih: _pilihTanggal,
          onGantiBulan: _gantiBulan,
        ),
        const SizedBox(height: 14),
        JumlahPengunjung(
          dewasa: _dewasa,
          anak: _anak,
          bayi: _bayi,
          hargaDewasa: _hargaDewasa,
          hargaAnak: _hargaAnak,
          bisaTambahTiket: _tiket < _maksTiket,
          bisaTambahBayi: _bayi < _dewasa,
          onDewasa: _ubahDewasa,
          onAnak: _ubahAnak,
          onBayi: _ubahBayi,
        ),
      ],
    );
  }

  // tampil kalau kuota gagal dimuat
  Widget _galatMuat() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40, color: AppColor.abu),
            const SizedBox(height: 8),
            Text(
              _errorMuat!,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColor.abu,
              ),
            ),
            TextButton(onPressed: _muat, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _latar,
        border: Border(
          bottom: BorderSide(color: AppColor.abu.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppColor.ungu),
              ),
              Expanded(
                child: Text(
                  'Atur Jadwal & Pengunjung',
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

  // ---------- bar bawah ----------

  Widget _barTotal() {
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _tampilRincian,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Bayar ($_tiket Tiket)',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: AppColor.hitam.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.info_outline,
                            size: 13,
                            color: AppColor.abu,
                          ),
                        ],
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatRupiah(_total),
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                // nonaktif saat kuota belum dimuat, gagal dimuat, atau penuh
                onPressed: _bisaLanjut ? _lanjut : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.ungu,
                  foregroundColor: AppColor.putih,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lanjut Pemesanan',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // tap ikon (i) di "Total Bayar": rincian harga
  void _tampilRincian() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.putih,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rincian Harga',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColor.hitam,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatTanggal(_tanggal),
              style: GoogleFonts.manrope(fontSize: 10.5, color: AppColor.abu),
            ),
            const SizedBox(height: 10),
            if (_dewasa > 0)
              _barisRincian(
                'Dewasa × $_dewasa',
                formatRupiah(_dewasa * _hargaDewasa),
              ),
            if (_anak > 0)
              _barisRincian('Anak × $_anak', formatRupiah(_anak * _hargaAnak)),
            if (_bayi > 0) _barisRincian('Bayi × $_bayi', 'Gratis'),
            Divider(color: AppColor.abu.withValues(alpha: 0.2)),
            _barisRincian('Total', formatRupiah(_total), tebal: true),
          ],
        ),
      ),
    );
  }

  Widget _barisRincian(String kiri, String kanan, {bool tebal = false}) {
    final gaya = GoogleFonts.manrope(
      fontSize: 12,
      fontWeight: tebal ? FontWeight.w800 : FontWeight.w600,
      color: AppColor.hitam,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(kiri, style: gaya)),
          Text(kanan, style: gaya),
        ],
      ),
    );
  }
}