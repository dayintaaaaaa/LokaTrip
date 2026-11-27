import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_color.dart';
import '../../core/format_rupiah.dart';
import '../../core/format_waktu.dart';
import '../../models/data_checkout.dart';
import '../../services/pemesanan_service.dart';
import '../../widgets/gambar_wisata.dart';
import 'checkout_widgets/stepper_checkout.dart';
import 'pembayaran_screens.dart';

class MetodePembayaranScreens extends StatefulWidget {
  final DataCheckout data;

  const MetodePembayaranScreens({super.key, required this.data});

  @override
  State<MetodePembayaranScreens> createState() =>
      _MetodePembayaranScreensState();
}

class _MetodePembayaranScreensState extends State<MetodePembayaranScreens> {
  // 0 QRIS, 1 VA, 2 Dompet Digital, 3 Kartu, 4 PayLater
  int _metode = 0;
  final Map<int, String> _pilihan = {1: 'BCA', 2: 'GoPay'};

  Duration _sisa = const Duration(minutes: 15);
  Timer? _timer;

  final _service = PemesananService();

  HasilPemesanan? _hasil;
  bool _memproses = false;

  late final String _kodeDummy =
      'LKT-${DateTime.now().millisecondsSinceEpoch % 10000000}';

  DataCheckout get _d => widget.data;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sisa.inSeconds <= 0) {
        _timer?.cancel();
        if (mounted) setState(() {});
        return;
      }
      setState(() => _sisa -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _labelMetode => switch (_metode) {
        0 => 'QRIS Instan',
        1 => 'Virtual Account ${_pilihan[1]}',
        2 => _pilihan[2]!,
        3 => 'Kartu Kredit',
        _ => 'PayLater',
      };

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(teks, style: GoogleFonts.manrope())),
    );
  }

  Future<String?> _siapkanPesanan() async {
    final p = _d.pesanan;

    if (p.paket.idPaket == null) return _kodeDummy;

    setState(() => _memproses = true);
    try {
      _hasil ??= await _service.buat(
        idPaket: p.paket.idPaket!,
        tanggal: p.tanggal,
        jumlahPerTipe: {
          'dewasa': p.dewasa,
          'anak_anak': p.anak,
          'balita': p.bayi,
        },
      );
    } on PemesananGagal catch (e) {
      _pesan(e.pesan);
      return null;
    } finally {
      if (mounted) setState(() => _memproses = false);
    }

    if (_hasil!.totalBayar != _d.rincian.total) {
      _pesan('Harga tiket berubah, silakan ulangi pemesanan');
      return null;
    }
    return _hasil!.kodePesan;
  }

  Future<void> _bayar() async {
    if (_memproses) return;

    if (_sisa.inSeconds <= 0) {
      _pesan('Waktu pembayaran habis, ulangi pemesanan');
      return;
    }

    final kode = await _siapkanPesanan();
    if (kode == null || !mounted) return;

    final Widget tujuan = QrisScreens(data: _d, orderId: kode);

    Navigator.push(context, MaterialPageRoute(builder: (_) => tujuan));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ringkasan(),
                  const SizedBox(height: 18),
                  Text(
                    'Pilih Metode Pembayaran',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _metodeKartu(
                    index: 0,
                    icon: Icons.qr_code_2,
                    judul: 'QRIS Instan',
                    sub: 'Scan dengan aplikasi pembayaran QRIS',
                    info: const ['QRIS'],
                  ),
                ],
              ),
            ),
          ),
          _bawah(),
        ],
      ),
    );
  }

  // ================== HEADER + STEPPER ==================
  Widget _header() {
    final habis = _sisa.inSeconds <= 0;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.putih,
        border: Border(
          bottom: BorderSide(color: AppColor.abu.withValues(alpha: 0.15)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColor.hitam,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Metode Pembayaran',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: habis
                          ? AppColor.abu.withValues(alpha: 0.3)
                          : AppColor.kuning.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: AppColor.kuning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatWaktu(_sisa),
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColor.kuning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: StepperCheckout(aktif: 2),
            ),
          ],
        ),
      ),
    );
  }

  // ================== RINGKASAN ==================
  Widget _ringkasan() {
    final p = _d.pesanan;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _dekor(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: GambarWisata(path: p.detail.gambar),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.biru.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'TIKET WISATA',
                        style: GoogleFonts.manrope(
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          color: AppColor.ungu,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tglPendek(p.tanggal),
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  p.detail.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                Text(
                  '${p.teksTamu} • ${p.paket.namaPendek}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    color: AppColor.abu,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL TAGIHAN',
                style: GoogleFonts.manrope(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  color: AppColor.abu,
                ),
              ),
              Text(
                formatRupiah(_d.rincian.total),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.ungu,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== KARTU METODE ==================
  Widget _metodeKartu({
    required int index,
    required IconData icon,
    required String judul,
    required String sub,
    List<String> info = const [],
    List<String> dropdown = const [],
  }) {
    final aktif = _metode == index;
    final bisaPilih = dropdown.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _metode = index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColor.putih,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: aktif
                  ? AppColor.ungu
                  : AppColor.abu.withValues(alpha: 0.2),
              width: aktif ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColor.latar,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: AppColor.ungu),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judul,
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bisaPilih)
                    Icon(
                      aktif
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColor.hitam,
                    )
                  else
                    Icon(
                      aktif
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: aktif ? AppColor.ungu : AppColor.abu,
                    ),
                ],
              ),
              if (aktif && info.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: info
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.latar,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColor.abu.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            t,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColor.hitam.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (aktif && bisaPilih) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: dropdown.map((t) {
                    final dipilih = _pilihan[index] == t;
                    return InkWell(
                      onTap: () => setState(() => _pilihan[index] = t),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: dipilih ? AppColor.ungu : AppColor.latar,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: dipilih
                                ? AppColor.putih
                                : AppColor.hitam,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metodeKecil(
    int index,
    IconData icon,
    String judul,
    String sub,
    Color warnaSub,
  ) {
    final aktif = _metode == index;
    return InkWell(
      onTap: () => setState(() => _metode = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.putih,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: aktif
                ? AppColor.ungu
                : AppColor.abu.withValues(alpha: 0.2),
            width: aktif ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColor.ungu),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      color: warnaSub,
                      fontWeight: warnaSub == AppColor.kuning
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              aktif
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: aktif ? AppColor.ungu : AppColor.abu,
            ),
          ],
        ),
      ),
    );
  }

  // ================== BAR BAWAH ==================
  Widget _bawah() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PEMBAYARAN',
                    style: GoogleFonts.manrope(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColor.abu,
                    ),
                  ),
                  Text(
                    formatRupiah(_d.rincian.total),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.ungu,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _memproses ? null : _bayar,
              icon: _memproses
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.putih,
                      ),
                    )
                  : const Icon(Icons.lock_outline, size: 16),
              label: Text(
                _memproses ? 'Memproses...' : 'Bayar Sekarang',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _dekor() {
    return BoxDecoration(
      color: AppColor.putih,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: AppColor.abu.withValues(alpha: 0.15),
      ),
    );
  }
}