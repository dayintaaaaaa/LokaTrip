import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_color.dart';
import '../../core/format_rupiah.dart';
import '../../core/format_waktu.dart';
import '../../models/data_checkout.dart';
import '../../services/pemesanan_service.dart';
import 'bukti_transaksi_screens.dart';
import 'lokapay_demo_scanner.dart';

// Catat pembayaran ke Supabase (simulasi, khusus pengembangan), lalu buka
// bukti transaksi. Wisata dummy (tanpa idPaket) tidak punya pesanan di
// database, jadi langsung ke bukti transaksi seperti sebelumnya.
Future<void> _prosesBayar({
  required BuildContext context,
  required DataCheckout data,
  required String orderId,
  required String metodeLabel,
  required String metodeDb,
  String? penyedia,
  required ValueChanged<bool> sedangMemproses,
}) async {
  debugPrint(
    'Simulasi bayar ditekan: orderId=$orderId '
    'idPaket=${data.pesanan.paket.idPaket} metode=$metodeDb',
  );

  if (data.pesanan.paket.idPaket != null) {
    sedangMemproses(true);
    try {
      // DIAGNOSIS (hapus setelah masalah ketemu): hanya mencetak ada/tidaknya,
      // JANGAN mencetak isi header karena berisi token login.
      final klien = Supabase.instance.client;
      final h = klien.rest.headers;
      debugPrint(
        'apikey ada? ${(h['apikey'] ?? '').isNotEmpty} | '
        'sesi login ada? ${klien.auth.currentSession != null}',
      );

      await PemesananService().bayarSimulasi(
        kodePesan: orderId,
        metode: metodeDb,
        penyedia: penyedia,
      );
      debugPrint('Simulasi bayar berhasil');
    } on PemesananGagal catch (e) {
      debugPrint('Simulasi bayar gagal: ${e.pesan}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.teknis == null ? e.pesan : '${e.pesan}\n[${e.teknis}]',
              style: GoogleFonts.manrope(),
            ),
          ),
        );
      }
      return;
    } finally {
      sedangMemproses(false);
    }
  }

  if (!context.mounted) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => BuktiTransaksiScreens(
        data: data,
        orderId: orderId,
        metode: metodeLabel,
      ),
    ),
  );
}

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
  Timer? _statusTimer;
  bool _memproses = false;
  bool _checkingStatus = false;
  bool _creatingQr = false;
  Uint8List? _midtransQrBytes;
  String? _midtransQrUrl;
  String? _qrError;

  bool get _demoOnly => widget.data.pesanan.paket.idPaket == null;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_sisa.inSeconds <= 0) {
        _timer?.cancel();
        _statusTimer?.cancel();
        if (mounted) setState(() {});
        return;
      }
      setState(() => _sisa -= const Duration(seconds: 1));
    });
    if (!_demoOnly) {
      _buatQrMidtrans();
      _pantauStatusPembayaran();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _info(String teks) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(teks, style: GoogleFonts.manrope())));
  }

  Future<void> _buatQrMidtrans() async {
    if (_creatingQr) return;
    setState(() {
      _creatingQr = true;
      _qrError = null;
    });
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'create-midtrans-qris',
        body: {
          'invoice_number': widget.orderId,
          'name': widget.data.nama,
          'email': widget.data.email,
        },
      );
      final body = response.data;
      if (body is! Map ||
          body['qr_image_base64'] is! String ||
          body['qr_image_url'] is! String) {
        throw Exception(
          body is Map
              ? body['error']?.toString()
              : 'Respons Midtrans tidak valid.',
        );
      }
      final bytes = base64Decode(body['qr_image_base64'] as String);
      if (mounted) {
        setState(() {
          _midtransQrBytes = bytes;
          _midtransQrUrl = body['qr_image_url'] as String;
        });
      }
    } catch (error) {
      if (mounted)
        setState(() => _qrError = 'QR Midtrans gagal dibuat: $error');
    } finally {
      if (mounted) setState(() => _creatingQr = false);
    }
  }

  void _pantauStatusPembayaran() {
    _statusTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_checkingStatus || !mounted || _sisa.inSeconds <= 0) return;
      _checkingStatus = true;
      try {
        final order = await Supabase.instance.client
            .from('pemesanan')
            .select('status_pesan')
            .eq('kode_pesan', widget.orderId)
            .maybeSingle();
        if (order?['status_pesan'] == 'aktif' && mounted) {
          _statusTimer?.cancel();
          _simulasiBerhasil();
        }
      } catch (error) {
        debugPrint('Gagal mengecek status Midtrans: $error');
      } finally {
        _checkingStatus = false;
      }
    });
  }

  Future<void> _salinUrlQr() async {
    final url = _midtransQrUrl;
    if (url == null) return;
    await Clipboard.setData(ClipboardData(text: url));
    _info('URL QR disalin. Tempelkan di Midtrans QRIS Simulator.');
  }

  Future<void> _bukaSimulatorMidtrans() async {
    final url = Uri.parse(
      'https://simulator.sandbox.midtrans.com/openapi/qris/index',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _info('Simulator Midtrans tidak dapat dibuka.');
    }
  }

  Future<void> _bukaLokaPayDemo() async {
    final paidOrder = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const LokaPayDemoScanner()),
    );
    if (paidOrder == widget.orderId && mounted) {
      _simulasiBerhasil();
    } else if (paidOrder != null && mounted) {
      _info('Pesanan $paidOrder dibayar dalam simulasi.');
    }
  }

  void _simulasiBerhasil() {
    _prosesBayar(
      context: context,
      data: widget.data,
      orderId: widget.orderId,
      metodeLabel: _demoOnly ? 'QRIS Demo' : 'QRIS Midtrans Sandbox',
      metodeDb: 'qris',
      penyedia: _demoOnly ? 'LokaPay Demo' : 'Midtrans Sandbox',
      sedangMemproses: (v) {
        if (mounted) setState(() => _memproses = v);
      },
    );
  }

  Widget _qrImage() {
    if (_demoOnly) {
      return QrImageView(
        data: jsonEncode({
          'app': 'lokatrip-demo',
          'order': widget.orderId,
          'amount': widget.data.rincian.total,
        }),
        size: 180,
        backgroundColor: Colors.white,
        foregroundColor: AppColor.ungu,
      );
    }
    final image = _midtransQrBytes;
    if (image != null) return Image.memory(image, width: 180, height: 180);
    if (_qrError != null) {
      return SizedBox(
        width: 180,
        height: 180,
        child: Center(child: Text(_qrError!, textAlign: TextAlign.center)),
      );
    }
    return const SizedBox(
      width: 180,
      height: 180,
      child: Center(child: CircularProgressIndicator()),
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
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.biru.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _demoOnly
                                    ? 'QR DEMO LOKATRIP'
                                    : 'MIDTRANS SANDBOX',
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
                              width: 2,
                            ),
                          ),
                          child: Opacity(
                            opacity: habis ? 0.25 : 1,
                            child: _qrImage(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _demoOnly
                              ? 'LOKATRIP INDONESIA'
                              : 'MIDTRANS QRIS SANDBOX',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                        Text(
                          _demoOnly
                              ? 'QR demo lokal - bukan QRIS asli'
                              : 'Transaksi uji coba; jangan scan dengan aplikasi pembayaran sungguhan',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            color: AppColor.abu,
                          ),
                        ),
                        if (!_demoOnly && _midtransQrUrl != null) ...[
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _salinUrlQr,
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Salin URL QR untuk simulator'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _caraBayar(
                    _demoOnly
                        ? [
                            'Untuk memindai, buka LokaPay Demo di perangkat lain.',
                            'Pindai QR demo pesanan ini.',
                            'Ini hanya simulasi; tidak ada saldo yang terpotong.',
                          ]
                        : [
                            'Salin URL QR di atas, lalu buka QRIS Simulator Midtrans.',
                            'Tempel URL QR di simulator dan jalankan pembayaran uji.',
                            'Kembali ke aplikasi; status akan berubah setelah webhook diterima.',
                          ],
                  ),
                  if (!_demoOnly && _qrError != null)
                    TextButton.icon(
                      onPressed: _creatingQr ? null : _buatQrMidtrans,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba buat QR lagi'),
                    ),
                ],
              ),
            ),
          ),
          if (_demoOnly) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: OutlinedButton.icon(
                onPressed: habis || _memproses ? null : _bukaLokaPayDemo,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan dengan LokaPay Demo'),
              ),
            ),
            _tombolBawah(
              icon: Icons.shield_outlined,
              teks: 'Simulasi Bayar Berhasil',
              onTap: habis ? null : _simulasiBerhasil,
              memproses: _memproses,
            ),
          ] else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Menunggu pembayaran dari Midtrans...'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _bukaSimulatorMidtrans,
                      child: const Text('Buka Simulator'),
                    ),
                  ],
                ),
              ),
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
  bool _memproses = false;

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

  // nilai enum metode_bayar_enum di database
  // (PayLater belum punya nilai enum, jadi ditolak server)
  String get _metodeDb => switch (widget.jenis) {
    1 => 'virtual_account',
    2 => 'dompet_digital',
    3 => 'kartu_kredit',
    _ => 'paylater',
  };

  // TODO: status lunas seharusnya datang dari webhook payment gateway.
  void _simulasiBerhasil() {
    _prosesBayar(
      context: context,
      data: widget.data,
      orderId: widget.orderId,
      metodeLabel: widget.metode,
      metodeDb: _metodeDb,
      penyedia: widget.metode,
      sedangMemproses: (v) {
        if (mounted) setState(() => _memproses = v);
      },
    );
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
                  _kartuOrder(
                    context,
                    widget.orderId,
                    widget.data.rincian.total,
                  ),
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
                                  Clipboard.setData(
                                    ClipboardData(text: _nomor),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Nomor VA disalin',
                                        style: GoogleFonts.manrope(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: AppColor.abu,
                                ),
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
            onTap: habis ? null : _simulasiBerhasil,
            memproses: _memproses,
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
                  Text(
                    'Total  ',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColor.abu,
                    ),
                  ),
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
  bool memproses = false,
}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    color: AppColor.putih,
    child: SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: memproses ? null : onTap,
          icon: memproses
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.putih,
                  ),
                )
              : Icon(icon, size: 17),
          label: Text(
            memproses ? 'Memproses...' : teks,
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
