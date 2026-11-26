import 'package:flutter/material.dart';

import '../core/mitra_theme.dart';
import '../services/ai_mitra_service.dart';

class TombolAiDeskripsiMitra extends StatefulWidget {
  const TombolAiDeskripsiMitra({
    super.key,
    required this.ambilData,
    required this.onPakai,
  });

  final Map<String, String> Function() ambilData;
  final ValueChanged<String> onPakai;

  @override
  State<TombolAiDeskripsiMitra> createState() =>
      _TombolAiDeskripsiMitraState();
}

class _TombolAiDeskripsiMitraState extends State<TombolAiDeskripsiMitra> {
  final _ai = AiMitraService();
  bool _loading = false;

  void _pesan(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _buat() async {
    if (_loading) return;
    final data = Map<String, String>.from(widget.ambilData())
      ..removeWhere((_, value) => value.trim().isEmpty);
    if ((data['nama_wisata'] ?? '').trim().isEmpty) {
      _pesan('Isi nama wisata dulu ya.');
      return;
    }

    setState(() => _loading = true);
    try {
      final deskripsi = await _ai.buatDeskripsi(data);
      if (!mounted) return;
      final pakai = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Saran deskripsi dari AI'),
          content: SingleChildScrollView(child: Text(deskripsi)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Pakai'),
            ),
          ],
        ),
      );
      if (pakai == true && mounted) widget.onPakai(deskripsi);
    } on AiMitraException catch (error) {
      if (mounted) _pesan(error.pesan);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _loading ? null : _buat,
        style: TextButton.styleFrom(foregroundColor: MitraPalette.primary),
        icon: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome_rounded, size: 18),
        label: Text(_loading ? 'AI menulis...' : 'Buat dengan AI'),
      ),
    );
  }
}