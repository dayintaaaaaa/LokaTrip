import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/mitra_theme.dart';

import '../../core/api_client.dart';
import '../../core/session_manager.dart';

class EditWisataMitraScreen extends StatefulWidget {
  const EditWisataMitraScreen({super.key, required this.wisata});

  final Map<String, dynamic> wisata;

  @override
  State<EditWisataMitraScreen> createState() => _EditWisataMitraScreenState();
}

class _EditWisataMitraScreenState extends State<EditWisataMitraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _city = TextEditingController();
  final _open = TextEditingController();
  final _close = TextEditingController();
  final List<_PackageEditor> _packages = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final row = widget.wisata;
    _name.text = row['nama_wisata']?.toString() ?? '';
    _description.text = row['deskripsi']?.toString() ?? '';
    _location.text = row['lokasi']?.toString() ?? '';
    _city.text = row['kota']?.toString() ?? '';
    _open.text = _displayTime(row['jam_buka']?.toString());
    _close.text = _displayTime(row['jam_tutup']?.toString());

    final packageRows = row['paket_wisata'];
    if (packageRows is List) {
      for (final item in packageRows.whereType<Map<String, dynamic>>()) {
        final details = item['detail_paket'];
        final priceEditors = <_PriceEditor>[];
        if (details is List) {
          for (final detail in details.whereType<Map<String, dynamic>>()) {
            final id = (detail['id_detail_paket'] as num?)?.toInt();
            if (id == null) continue;
            priceEditors.add(
              _PriceEditor(
                id: id,
                visitorType: detail['tipe_pengunjung']?.toString() ?? 'Tiket',
                price: TextEditingController(
                  text: detail['harga']?.toString() ?? '',
                ),
              ),
            );
          }
        }
        final id = (item['id_paket'] as num?)?.toInt();
        if (id == null) continue;
        _packages.add(
          _PackageEditor(
            id: id,
            name: TextEditingController(
              text: item['nama_paket']?.toString() ?? '',
            ),
            prices: priceEditors,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _location.dispose();
    _city.dispose();
    _open.dispose();
    _close.dispose();
    for (final package in _packages) {
      package.name.dispose();
      for (final price in package.prices) {
        price.price.dispose();
      }
    }
    super.dispose();
  }

  String _displayTime(String? value) {
    if (value == null) return '';
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) return value;
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }

  String? _databaseTime(String value) {
    final match = RegExp(r'^(\d{1,2})[:.](\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }

  int? _priceValue(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    final openTime = _databaseTime(_open.text);
    final closeTime = _databaseTime(_close.text);
    if (openTime == null || closeTime == null) {
      _message('Jam buka dan tutup harus memakai format HH:MM.');
      return;
    }
    final token = await SessionManager.currentMitraToken();
    if (token == null) {
      _message('Sesi mitra tidak ditemukan. Silakan masuk kembali.');
      return;
    }
    setState(() => _saving = true);
    try {
      final idWisata = (widget.wisata['id_wisata'] as num).toInt();
      await MitraApi.updateWisata(
        token: token,
        idWisata: idWisata,
        values: {
          'nama_wisata': _name.text.trim(),
          'deskripsi': _description.text.trim(),
          'lokasi': _location.text.trim(),
          'kota': _city.text.trim().isEmpty ? null : _city.text.trim(),
          'jam_buka': openTime,
          'jam_tutup': closeTime,
        },
      );
      for (final package in _packages) {
        await MitraApi.updatePaket(
          token: token,
          idPaket: package.id,
          values: {'nama_paket': package.name.text.trim()},
        );
        for (final detail in package.prices) {
          await MitraApi.updateHargaPaket(
            token: token,
            idDetailPaket: detail.id,
            harga: _priceValue(detail.price.text)!,
          );
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wisata, paket, dan harga berhasil diperbarui.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: mitraTheme(Theme.of(context)),
    child: Scaffold(
      backgroundColor: MitraPalette.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Edit wisata',
          style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            _section('Informasi wisata', Icons.landscape_outlined, [
              _field(_name, 'Nama wisata'),
              _field(_description, 'Deskripsi', maxLines: 4),
              _field(_location, 'Alamat / lokasi'),
              _field(_city, 'Kota'),
              Row(
                children: [
                  Expanded(child: _field(_open, 'Jam buka', hint: '08:00')),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_close, 'Jam tutup', hint: '17:00')),
                ],
              ),
            ]),
            const SizedBox(height: 14),
            if (_packages.isEmpty)
              _section('Paket dan harga', Icons.sell_outlined, const [
                Text('Wisata ini belum memiliki paket tiket.'),
              ])
            else
              for (final package in _packages) ...[
                _section('Paket dan harga', Icons.sell_outlined, [
                  _field(package.name, 'Nama paket'),
                  for (final detail in package.prices) ...[
                    const SizedBox(height: 10),
                    _field(
                      detail.price,
                      'Harga ${detail.visitorType}',
                      keyboardType: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      prefix: 'Rp ',
                    ),
                  ],
                ]),
                const SizedBox(height: 14),
              ],
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Menyimpan…' : 'Simpan perubahan'),
              style: FilledButton.styleFrom(
                backgroundColor: MitraPalette.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _section(String title, IconData icon, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: MitraPalette.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: MitraPalette.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    String? prefix,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Wajib diisi.';
        if (label.startsWith('Harga') && _priceValue(value) == null) {
          return 'Masukkan harga yang valid.';
        }
        if (label == 'Jam buka' || label == 'Jam tutup') {
          if (_databaseTime(value) == null) return 'Gunakan format HH:MM.';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: const Color(0xFFFBFCFE),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: MitraPalette.line),
        ),
      ),
    ),
  );
}

class _PackageEditor {
  _PackageEditor({required this.id, required this.name, required this.prices});

  final int id;
  final TextEditingController name;
  final List<_PriceEditor> prices;
}

class _PriceEditor {
  _PriceEditor({
    required this.id,
    required this.visitorType,
    required this.price,
  });

  final int id;
  final String visitorType;
  final TextEditingController price;
}
