import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format_rupiah.dart';
import '../../core/format_waktu.dart';
import '../../models/data_checkout.dart';
import '../../widgets/qr_palsu.dart';
import 'bukti_transaksi_screens.dart';

// ================== PEMBAYARAN QRIS ==================
class QrisScreens extends StatefulWidget {
  final DataCheckout data;
  final String orderId;

  const QrisScreens({super.key, required this.data, required this.orderId});

  @override
  State<QrisScreens> createState() => _QrisScreensState();
}

class _QrisScreensState extends State<QrisScreens> {
  Duration _sisa = const Duration(minutes: 14, seconds: 59);
  Timer? _timer;

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

  void _info(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(teks, style: GoogleFonts.manrope())),
    );
  }

  void _simulasiBerhasil() {
    // TODO: status "paid" seharusnya datang dari webhook payment gateway,
    // tombol simulasi ini hanya untuk development.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BuktiTransaksiScreens(
          data: widget.data,
          orderId: widget.orderId,
          metode: 'QRIS Instan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habis = _sisa.inSeconds <= 0;
    final total = widget.data.rincian.total;

    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          _headerBiasa(context, 'Pembayaran QRIS'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  _barTimer(habis, _sisa),
                  const SizedBox(height: 10),
                  _kartuOrder(context, widget.orderId, total),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _dekor(),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'QRIS',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColor.kuning,
                              ),
                            ),
                            Text(
                              '  |  GPN',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColor.abu,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColor.biru.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'STANDAR NASIONAL',
                                style: GoogleFonts.manrope(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.ungu,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColor.ungu.withValues(alpha: 0.25),
                                width: 2),
                          ),
                          child: Opacity(
                            opacity: habis ? 0.25 : 1,
                            // TODO: ganti dengan QR asli dari payment gateway
                            child: QrPalsu(
                              seed: widget.orderId,
                              ukuran: 180,
                              warna: AppColor.ungu,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'LOKATRIP INDONESIA',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                        Text(
                          'NMID: ID102003928190',
                          style:
                              GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
                        ),
                        const SizedBox(height: 10),
                        Divider(
                            height: 1,
                            color: AppColor.abu.withValues(alpha: 0.2)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: ['GoPay', 'OVO', 'DANA', 'BCA', 'ShopeePay']
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColor.latar,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      t,
                                      style: GoogleFonts.manrope(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColor.hitam
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _tombolSekunder(
                          Icons.download_outlined,
                          'Unduh QR',
                          () => _info('Unduh QR: sambungkan ke QR asli / backend'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _tombolSekunder(
                          Icons.open_in_new,
                          'Buka di E-Wallet',
                          () => _info('Buka e-wallet: perlu deep link dari gateway'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _caraBayar([
                    'Buka aplikasi m-Banking atau e-wallet pilihan Anda.',
                    'Pindai (Scan) QR di atas & pastikan nominal ${formatRupiah(total)}.',
                    'Masukkan PIN, transaksi diverifikasi otomatis secara instan.',
                  ]),
                ],
              ),
            ),
          ),
          _tombolBawah(
            icon: Icons.shield_outlined,
            teks: 'Simulasi Bayar Berhasil',
            onTap: habis ? null : _simulasiBerhasil,
          ),
        ],
      ),
    );
  }
}

// ================== PEMBAYARAN LAIN (VA / E-Wallet / Kartu / PayLater) ==================
class PembayaranLainScreens extends StatefulWidget {
  final DataCheckout data;
  final String orderId;
  final String metode; // label, mis. "Virtual Account BCA"
  final int jenis; // 1 VA, 2 e-wallet, 3 kartu, 4 paylater

  const PembayaranLainScreens({
    super.key,
    required this.data,
    required this.orderId,
    required this.metode,
    required this.jenis,
  });

  @override
  State<PembayaranLainScreens> createState() => _PembayaranLainScreensState();
}

class _PembayaranLainScreensState extends State<PembayaranLainScreens> {
  Duration _sisa = const Duration(minutes: 14, seconds: 59);
  Timer? _timer;

  // TODO: nomor VA / link bayar berasal dari payment gateway
  late final String _nomor =
      '8077 ${(widget.orderId.hashCode.abs() % 100000000).toString().padLeft(8, '0')}';

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

  List<String> get _langkah => switch (widget.jenis) {
        1 => [
            'Buka m-Banking atau ATM, pilih menu Virtual Account.',
            'Masukkan nomor VA di atas dan cek nominal pembayaran.',
            'Konfirmasi dengan PIN, tiket terbit otomatis setelah lunas.',
          ],
        2 => [
            'Anda akan diarahkan ke aplikasi dompet digital pilihan.',
            'Periksa nominal pembayaran lalu konfirmasi.',
            'Masukkan PIN, tiket terbit otomatis setelah lunas.',
          ],
        3 => [
            'Masukkan data kartu pada halaman aman dari penyedia pembayaran.',
            'Verifikasi dengan kode OTP dari bank penerbit kartu.',
            'Tiket terbit otomatis setelah transaksi disetujui.',
          ],
        _ => [
            'Pilih tenor cicilan 0% yang tersedia.',
            'Setujui limit dan ketentuan PayLater.',
            'Tiket terbit otomatis setelah pengajuan disetujui.',
          ],
      };

  @override
  Widget build(BuildContext context) {
    final habis = _sisa.inSeconds <= 0;

    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          _headerBiasa(context, widget.metode),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  _barTimer(habis, _sisa),
                  const SizedBox(height: 10),
                  _kartuOrder(context, widget.orderId, widget.data.rincian.total),
                  if (widget.jenis == 1) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: _dekor(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOMOR VIRTUAL ACCOUNT',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColor.abu,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _nomor,
                                  style: GoogleFonts.manrope(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                    color: AppColor.ungu,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: _nomor));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Nomor VA disalin',
                                          style: GoogleFonts.manrope()),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.copy,
                                    size: 18, color: AppColor.abu),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _caraBayar(_langkah),
                ],
              ),
            ),
          ),
          _tombolBawah(
            icon: Icons.shield_outlined,
            teks: 'Simulasi Bayar Berhasil',
            onTap: habis
                ? null
                : () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuktiTransaksiScreens(
                          data: widget.data,
                          orderId: widget.orderId,
                          metode: widget.metode,
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

// ================== KOMPONEN BERSAMA ==================
Widget _headerBiasa(BuildContext context, String judul) {
  return Container(
    width: double.infinity,
    color: AppColor.latar,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColor.hitam),
            ),
            Expanded(
              child: Text(
                judul,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.help_outline, color: AppColor.abu, size: 22),
            const SizedBox(width: 4),
          ],
        ),
      ),
    ),
  );
}

Widget _barTimer(bool habis, Duration sisa) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColor.kuning.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColor.kuning.withValues(alpha: 0.4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.timer_outlined, size: 16, color: AppColor.kuning),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            habis ? 'Waktu pembayaran habis' : 'Selesaikan dalam',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColor.kuning,
            ),
          ),
        ),
        Text(
          formatWaktu(sisa),
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColor.kuning,
          ),
        ),
      ],
    ),
  );
}

Widget _kartuOrder(BuildContext context, String orderId, int total) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: _dekor(),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Order ID  ',
                  style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
                  children: [
                    TextSpan(
                      text: '#$orderId',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('Total  ',
                      style:
                          GoogleFonts.manrope(fontSize: 11, color: AppColor.abu)),
                  Text(
                    formatRupiah(total),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.ungu,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: orderId));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order ID disalin', style: GoogleFonts.manrope()),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.latar,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.copy, size: 13, color: AppColor.ungu),
                const SizedBox(width: 5),
                Text(
                  'Salin',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.ungu,
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

Widget _tombolSekunder(IconData icon, String teks, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.biru.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: AppColor.ungu),
          const SizedBox(width: 6),
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColor.ungu,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _caraBayar(List<String> langkah) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: _dekor(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CARA PEMBAYARAN CEPAT:',
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColor.abu,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(
          langkah.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${i + 1}.  ',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColor.ungu,
                  ),
                ),
                Expanded(
                  child: Text(
                    langkah[i],
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      height: 1.4,
                      color: AppColor.hitam.withValues(alpha: 0.8),
                    ),
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

Widget _tombolBawah({
  required IconData icon,
  required String teks,
  required VoidCallback? onTap,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    color: AppColor.putih,
    child: SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 17),
          label: Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.ungu,
            foregroundColor: AppColor.putih,
            disabledBackgroundColor: AppColor.abu.withValues(alpha: 0.3),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    ),
  );
}

BoxDecoration _dekor() {
  return BoxDecoration(
    color: AppColor.putih,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColor.abu.withValues(alpha: 0.15)),
  );
}