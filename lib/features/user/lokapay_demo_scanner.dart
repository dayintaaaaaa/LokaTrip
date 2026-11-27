import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/pemesanan_service.dart';

class LokaPayDemoScanner extends StatefulWidget {
  const LokaPayDemoScanner({super.key});

  @override
  State<LokaPayDemoScanner> createState() => _LokaPayDemoScannerState();
}

class _LokaPayDemoScannerState extends State<LokaPayDemoScanner> {
  bool _processing = false;
  String? _message;

  Future<void> _scan(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> ||
          decoded['app'] != 'lokatrip-demo' ||
          decoded['order'] is! String) {
        throw const FormatException();
      }
      payload = decoded;
    } catch (_) {
      if (mounted)
        setState(() => _message = 'QR bukan pembayaran demo LokaTrip ini.');
      return;
    }

    setState(() {
      _processing = true;
      _message = 'Memproses simulasi pembayaran…';
    });
    try {
      await PemesananService().bayarSimulasi(
        kodePesan: payload['order'] as String,
        metode: 'qris',
        penyedia: 'LokaPay Demo',
      );
      if (mounted) Navigator.pop(context, payload['order'] as String);
    } on PemesananGagal catch (e) {
      if (mounted)
        setState(() {
          _processing = false;
          _message = e.pesan;
        });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('LokaPay Demo')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Arahkan kamera ke QR demo LokaTrip. Ini simulasi lokal, bukan pembayaran sungguhan.',
          ),
        ),
        Expanded(child: MobileScanner(onDetect: _scan)),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_message!, textAlign: TextAlign.center),
          ),
        if (_processing)
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: CircularProgressIndicator(),
          ),
      ],
    ),
  );
}
