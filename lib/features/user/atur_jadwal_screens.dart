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
import 'atur_jadwal_widgets/jumlah_pengunjung.dart';
import 'atur_jadwal_widgets/kalender_kunjungan.dart';
import 'atur_jadwal_widgets/ringkasan_wisata.dart';

// Langkah pertama pemesanan: pilih tanggal kunjungan dan jumlah pengunjung.
class AturJadwalScreens extends StatefulWidget {
  final DetailWisata detail;
  final GrupTiket grup; // WNI / WNA yang dipilih di halaman detail
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

  late final DateTime _awal; // hari ini
  late final DateTime _akhir; // setahun ke depan
  late DateTime _bulan; // bulan yang tampil di kalender
  late DateTime _tanggal; // tanggal terpilih
  int _dewasa = 1;
  int _anak = 0;
  int _bayi = 0;

  Ketersediaan _info(DateTime t) =>
      KetersediaanDummy.untuk(t, widget.paket.harga);

  int get _hargaDewasa => _info(_tanggal).harga;
  int get _hargaAnak => KetersediaanDummy.hargaAnak(_hargaDewasa);
  int get _tiket => _dewasa + _anak; // bayi tidak dihitung
  int get _total => _dewasa * _hargaDewasa + _anak * _hargaAnak;

  // batas tiket = batas per transaksi, atau sisa kuota kalau lebih kecil
  int get _maksTiket => math.min(
    KetersediaanDummy.maksTiketPerTransaksi,
    _info(_tanggal).kuota,
  );

  @override
  void initState() {
    super.initState();
    final sekarang = DateTime.now();
    _awal = DateTime(sekarang.year, sekarang.month, sekarang.day);
    _akhir = DateTime(_awal.year + 1, _awal.month, _awal.day);
    _tanggal = _tanggalPertamaTersedia();
    _bulan = DateTime(_tanggal.year, _tanggal.month);
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
    final data = DataPemesanan(
      detail: widget.detail,
      grup: widget.grup,
      paket: widget.paket,
      tanggal: _tanggal,
      dewasa: _dewasa,
      anak: _anak,
      bayi: _bayi,
      hargaDewasa: _hargaDewasa,
      hargaAnak: _hargaAnak,
    );

    // TODO: ganti SnackBar ini dengan Navigator.push ke halaman berikutnya
    // (data pemesan / pembayaran) sambil membawa `data`.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${data.tiket} tiket • ${formatTanggal(data.tanggal)} • '
          '${formatRupiah(data.total)}',
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
              child: ListView(
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
              ),
            ),
          ],
        ),
        bottomNavigationBar: _barTotal(),
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
                    Text(
                      'Termasuk pajak & asuransi',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _lanjut,
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
            const SizedBox(height: 6),
            Text(
              'Harga sudah termasuk pajak & asuransi.',
              style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
            ),
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