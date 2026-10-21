import 'dart:async';
import 'package:flutter/material.dart';

class HitungMundur extends StatefulWidget {
  final DateTime berakhirPada;
  final Widget Function(String jam, String menit, String detik) builder;

  const HitungMundur({
    super.key,
    required this.berakhirPada,
    required this.builder,
  });

  @override
  State<HitungMundur> createState() => _HitungMundurState();
}

class _HitungMundurState extends State<HitungMundur> {
  Timer? _timer;
  Duration _sisa = Duration.zero;

  @override
  void initState() {
    super.initState();
    _hitung();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_hitung);
    });
  }

  void _hitung() {
    final selisih = widget.berakhirPada.difference(DateTime.now());
    _sisa = selisih.isNegative ? Duration.zero : selisih;
    if (_sisa == Duration.zero) _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel(); // wajib: hentikan timer saat widget dihapus
    super.dispose();
  }

  String _dua(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      _dua(_sisa.inHours),
      _dua(_sisa.inMinutes.remainder(60)),
      _dua(_sisa.inSeconds.remainder(60)),
    );
  }
}