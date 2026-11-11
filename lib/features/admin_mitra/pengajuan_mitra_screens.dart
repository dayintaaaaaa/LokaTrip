import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/mitra_bottom_navigator.dart';
import 'wisata_saya_mitra_screen.dart';

const _blue = Color(0xFF0646C7);
const _ink = Color(0xFF14243A);
const _muted = Color(0xFF697386);
const _ground = Color(0xFFF5F7FC);
const _line = Color(0xFFE5EAF3);
const _wash = Color(0xFFEDF3FF);
const _green = Color(0xFF087457);

class PengajuanMitraScreens extends StatefulWidget {
  const PengajuanMitraScreens({super.key});

  @override
  State<PengajuanMitraScreens> createState() => _PengajuanMitraScreensState();
}

class _PengajuanMitraScreensState extends State<PengajuanMitraScreens> {
  static const _draftKey = 'mitra_application_draft_v1';
  static const _steps = [
    'Info Wisata',
    'Tiket & Kuota',
    'Legalitas',
    'Pelacakan',
  ];
  final _infoForm = GlobalKey<FormState>();
  final _ticketForm = GlobalKey<FormState>();
  final _fields = {
    for (final name in [
      'destination',
      'description',
      'location',
      'ticket',
      'price',
      'quota',
      'hours',
      'nib',
      'license',
    ])
      name: TextEditingController(),
  };
  final _documents = <String, String>{};

  int _step = 0;
  String _category = 'Wisata Alam';
  String _photoName = '';
  String _submissionId = '';
  Uint8List? _photo;
  bool _agreed = false;
  bool _loading = true;

  String _value(String key) => _fields[key]!.text;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _restoreDraft() async {
    final saved = (await SharedPreferences.getInstance()).getString(_draftKey);
    if (saved != null) {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      for (final entry in _fields.entries) {
        entry.value.text = data[entry.key] as String? ?? '';
      }
      _step = ((data['step'] as int?) ?? 0).clamp(0, 3).toInt();
      _category = data['category'] as String? ?? _category;
      _submissionId = data['submissionId'] as String? ?? '';
      _agreed = data['agreed'] as bool? ?? false;
      _documents.addAll(
        Map<String, String>.from(data['documents'] as Map? ?? {}),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveDraft() async {
    final Map<String, Object> data = {
      for (final entry in _fields.entries) entry.key: entry.value.text,
    };
    data.addAll({
      'step': _step,
      'category': _category,
      'submissionId': _submissionId,
      'agreed': _agreed,
      'documents': _documents,
    });
    await (await SharedPreferences.getInstance()).setString(
      _draftKey,
      jsonEncode(data),
    );
  }

  void _changed() => _saveDraft();

  Future<void> _pickPhoto() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Foto wisata',
            extensions: ['jpg', 'jpeg', 'png', 'webp'],
          ),
        ],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photo = bytes;
        _photoName = file.name;
      });
    } catch (error, stackTrace) {
      debugPrint('Gagal memilih foto wisata: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) _message('Foto tidak dapat dibuka. Pilih file gambar lain.');
    }
  }

  Future<void> _pickDocument(String title) async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Dokumen',
            extensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
        ],
      );
      if (file == null) return;
      if (!mounted) return;
      setState(() => _documents[title] = file.name);
      await _saveDraft();
    } catch (error, stackTrace) {
      debugPrint('Gagal memilih dokumen: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) _message('Dokumen tidak dapat dibuka. Pilih file lain.');
    }
  }

  Future<void> _next() async {
    if (_step == 0 && !(_infoForm.currentState?.validate() ?? false)) return;
    if (_step == 1 && !(_ticketForm.currentState?.validate() ?? false)) return;
    if (_step == 2 && !_agreed) {
      _message('Centang pernyataan legalitas sebelum melanjutkan.');
      return;
    }
    if (_step == 2) {
      final now = DateTime.now();
      _submissionId =
          'SUB-${now.year}-${now.millisecondsSinceEpoch.remainder(10000).toString().padLeft(4, '0')}';
    }
    setState(() => _step = (_step + 1).clamp(0, 3).toInt());
    await _saveDraft();
  }

  Future<void> _back() async {
    if (_step == 0) return;
    setState(() => _step--);
    await _saveDraft();
  }

  Future<void> _submitAndGoToWisataSaya() async {
    await _saveDraft();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mitra_application_submitted', true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan kemitraan berhasil dikirim ke Admin LokaTrip!'),
        backgroundColor: Color(0xFF059669),
      ),
    );
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const WisataSayaMitraScreen(),
        transitionDuration: Duration.zero,
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _ground,
    body: SafeArea(
      child: Column(
        children: [
          _header(),
          _progress(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _blue))
                : LayoutBuilder(
                    builder: (context, size) => SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        size.maxWidth > 900 ? 32 : 16,
                        20,
                        size.maxWidth > 900 ? 32 : 16,
                        24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: _stage(size.maxWidth > 900),
                        ),
                      ),
                    ),
                  ),
          ),
          if (!_loading) _actions(),
        ],
      ),
    ),
    bottomNavigationBar: MitraBottomNavigator(
      currentIndex: 0,
      onTap: (index) async {
        if (index == 0) return;
        await _saveDraft();
        if (!context.mounted) return;
        MitraBottomNavigator.navigateTo(context, index);
      },
    ),
  );

  Widget _header() => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: _line)),
    ),
    child: Row(
      children: [
        IconButton(
          tooltip: _step == 0 ? 'Ke Wisata Saya' : 'Tahap sebelumnya',
          onPressed: () {
            if (_step == 0) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const WisataSayaMitraScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
            } else {
              _back();
            }
          },
          icon: const Icon(Icons.arrow_back, color: _ink),
        ),
        Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 19),
        const SizedBox(width: 10),
        Expanded(child: Text(_steps[_step], style: _textStyle(15, bold: true))),
        TextButton.icon(
          onPressed: _loading
              ? null
              : () async {
                  await _saveDraft();
                  if (mounted) _message('Draf disimpan di perangkat ini.');
                },
          icon: const Icon(Icons.bookmark_border, size: 18),
          label: const Text('Simpan draf'),
        ),
      ],
    ),
  );

  Widget _progress() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 13),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Row(
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              Expanded(child: _stepDot(i)),
              if (i < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 19),
                    color: i < _step ? _blue : _line,
                  ),
                ),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _stepDot(int index) {
    final passed = index < _step;
    final current = index == _step;
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: passed || current ? _blue : const Color(0xFFE6ECF7),
          child: passed
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text(
                  '${index + 1}',
                  style: _textStyle(12, bold: true, color: Colors.white),
                ),
        ),
        const SizedBox(height: 5),
        Text(
          '${index + 1}. ${_steps[index]}',
          textAlign: TextAlign.center,
          style: _textStyle(
            9,
            bold: current || passed,
            color: current || passed ? _blue : _muted,
          ),
        ),
      ],
    );
  }

  Widget _stage(bool wide) => switch (_step) {
    0 => _infoStage(),
    1 => _ticketStage(),
    2 => _legalStage(),
    _ => _trackingStage(),
  };

  Widget _infoStage() => Form(
    key: _infoForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _intro(
          'Tahap 1: Info wisata',
          'Isi identitas destinasi dan foto utama.',
        ),
        const SizedBox(height: 14),
        _panel('Identitas destinasi', Icons.explore_outlined, [
          _field('destination', 'Nama destinasi', required: true),
          _field('description', 'Deskripsi singkat', required: true, lines: 3),
          _label('Kategori wisata'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: _decoration(),
            items:
                const [
                      'Wisata Alam',
                      'Wisata Budaya',
                      'Wisata Bahari',
                      'Taman Rekreasi',
                      'Petualangan',
                    ]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _category = value);
              _changed();
            },
          ),
          _field(
            'location',
            'Lokasi dan kota',
            required: true,
            icon: Icons.location_on_outlined,
          ),
        ]),
        const SizedBox(height: 14),
        _panel('Foto utama wisata', Icons.photo_camera_outlined, [
          if (_photo == null)
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: _wash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.landscape_outlined, size: 38, color: _blue),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _photo!,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image_outlined),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_photo == null ? 'Pilih foto wisata' : 'Ganti foto'),
          ),
          if (_photoName.isNotEmpty)
            Text(_photoName, style: _textStyle(11, color: _muted)),
        ]),
      ],
    ),
  );

  Widget _ticketStage() => Form(
    key: _ticketForm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _intro(
          'Tahap 2: Tiket dan kuota',
          'Tentukan harga tiket dan batas pengunjung harian.',
        ),
        const SizedBox(height: 14),
        _panel('Destinasi terpilih', Icons.landscape_outlined, [
          Text(_value('destination'), style: _textStyle(15, bold: true)),
          Text(
            '$_category • ${_value('location')}',
            style: _textStyle(12, color: _muted),
          ),
        ]),
        const SizedBox(height: 14),
        _panel('Paket tiket utama', Icons.confirmation_number_outlined, [
          _field('ticket', 'Nama paket tiket', required: true),
          _field(
            'price',
            'Harga tiket per orang (Rp)',
            required: true,
            keyboard: TextInputType.number,
          ),
          _field(
            'quota',
            'Kuota pengunjung per hari',
            required: true,
            keyboard: TextInputType.number,
          ),
          _field(
            'hours',
            'Jam operasional wisata',
            required: true,
            hint: 'Contoh: 01.00–12.00 WIB',
          ),
        ]),
      ],
    ),
  );

  Widget _legalStage() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _intro(
        'Tahap 3: Legalitas',
        'Masukkan nomor izin dan pilih berkas pendukung.',
      ),
      const SizedBox(height: 14),
      _panel('Nomor perizinan', Icons.badge_outlined, [
        _field('nib', 'Nomor Induk Berusaha (NIB)', required: true),
        _upload('NIB'),
        _field('license', 'Nomor izin usaha / TDUP', required: true),
        _upload('Izin usaha'),
      ]),
      const SizedBox(height: 12),
      _panel('Asuransi pengunjung', Icons.health_and_safety_outlined, [
        _upload('Asuransi'),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: _wash,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Checkbox(
              key: const Key('legal-declaration'),
              value: _agreed,
              onChanged: (value) {
                setState(() => _agreed = value ?? false);
                _changed();
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _agreed = !_agreed);
                  _changed();
                },
                child: Text(
                  'Saya menyatakan dokumen dan data yang diberikan benar.',
                  style: _textStyle(12),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'File hanya dipilih di perangkat ini; pengiriman ke server belum tersedia.',
        style: _textStyle(11, color: _muted),
      ),
    ],
  );

  Widget _upload(String title) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _wash,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            _documents.containsKey(title)
                ? Icons.check_circle
                : Icons.cloud_upload_outlined,
            color: _documents.containsKey(title) ? _green : _blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _documents[title] ?? '$title • PDF atau JPG',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _textStyle(12),
            ),
          ),
          TextButton(
            onPressed: () => _pickDocument(title),
            child: Text(_documents.containsKey(title) ? 'Ganti' : 'Pilih file'),
          ),
        ],
      ),
    ),
  );

  Widget _trackingStage() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _intro(
        'Tahap 4: Pelacakan pengajuan',
        'Periksa kembali ringkasan pengajuan wisata.',
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tag('SIMULASI LOKAL', color: const Color(0xFF9FF4D2)),
            const SizedBox(height: 10),
            Text(
              'Nomor pengajuan',
              style: _textStyle(12, color: Colors.white70),
            ),
            Text(
              '#$_submissionId',
              style: _textStyle(23, bold: true, color: Colors.white),
            ),
            Text(
              'Status: Menunggu Review Admin (simulasi)',
              style: _textStyle(12, bold: true, color: const Color(0xFF9FF4D2)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      _panel('Ringkasan wisata', Icons.terrain_outlined, [
        _summary('Destinasi', _value('destination')),
        _summary('Kategori', _category),
        _summary('Lokasi', _value('location')),
        _summary('Tiket', _value('ticket')),
        _summary('Harga', 'Rp ${_value('price')} / orang'),
        _summary('Kuota per hari', _value('quota')),
      ]),
      const SizedBox(height: 14),
      _panel('Alur verifikasi LokaTrip', Icons.timeline_outlined, [
        _timeline('Pengajuan disiapkan', 'Selesai', true),
        _timeline('Verifikasi berkas', 'Menunggu pengiriman', false),
        _timeline('Wisata siap tayang', 'Menunggu verifikasi', false),
      ]),
      const SizedBox(height: 12),
      _tag(
        'Belum terhubung ke server; pengajuan belum diterima admin.',
        color: _muted,
      ),
    ],
  );

  Widget _timeline(String title, String status, bool done) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      radius: 15,
      backgroundColor: done ? _green : _wash,
      child: Icon(
        done ? Icons.check : Icons.schedule,
        size: 17,
        color: done ? Colors.white : _blue,
      ),
    ),
    title: Text(title, style: _textStyle(12, bold: true)),
    subtitle: Text(status, style: _textStyle(11, color: _muted)),
  );

  Widget _summary(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: _textStyle(12, color: _muted)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Belum diisi' : value,
            style: _textStyle(12, bold: true),
          ),
        ),
      ],
    ),
  );

  Widget _actions() => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: _line)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final primary = FilledButton.icon(
              onPressed: _step == 3 ? _submitAndGoToWisataSaya : _next,
              icon: Icon(
                _step == 3 ? Icons.check_circle_outline : Icons.arrow_forward,
              ),
              label: Text(switch (_step) {
                0 => 'Lanjut ke Tahap 2: Tiket & Kuota',
                1 => 'Lanjut ke Tahap 3: Legalitas',
                2 => 'Siapkan Pengajuan Tahap 4',
                _ => 'Kirim Pengajuan & Buka Wisata Saya',
              }, textAlign: TextAlign.center),
              style: _primaryButton,
            );
            final secondary = OutlinedButton.icon(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(_step == 3 ? 'Edit pengajuan' : 'Kembali'),
              style: _secondaryButton,
            );
            if (constraints.maxWidth < 560) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  primary,
                  if (_step > 0) ...[const SizedBox(height: 8), secondary],
                ],
              );
            }
            return Row(
              children: [
                if (_step > 0) ...[
                  Expanded(child: secondary),
                  const SizedBox(width: 10),
                ],
                Expanded(flex: 2, child: primary),
              ],
            );
          },
        ),
      ),
    ),
  );

  Widget _intro(String title, String subtitle) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: _wash,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.verified_user_outlined, color: _blue),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _textStyle(14, bold: true)),
              const SizedBox(height: 3),
              Text(subtitle, style: _textStyle(12, color: _muted)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _panel(String title, IconData icon, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 19, color: _blue),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: _textStyle(15, bold: true))),
              ],
            ),
            const SizedBox(height: 13),
            ...children
                .expand((child) => [child, const SizedBox(height: 12)])
                .toList()
              ..removeLast(),
          ],
        ),
      );

  Widget _field(
    String id,
    String label, {
    bool required = false,
    int lines = 1,
    String? hint,
    TextInputType? keyboard,
    IconData? icon,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _label(label),
      TextFormField(
        key: Key(id),
        controller: _fields[id],
        maxLines: lines,
        keyboardType: keyboard,
        onChanged: (_) => _changed(),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? '$label wajib diisi'
                  : null
            : null,
        style: _textStyle(14),
        decoration: _decoration(hint: hint, icon: icon),
      ),
    ],
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: _textStyle(12, bold: true)),
  );

  InputDecoration _decoration({String? hint, IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 19, color: _muted),
        filled: true,
        fillColor: _wash,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _blue, width: 1.4),
        ),
      );

  Widget _tag(String text, {Color color = _blue}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: _textStyle(10, bold: true, color: color)),
  );
}

TextStyle _textStyle(double size, {bool bold = false, Color color = _ink}) =>
    GoogleFonts.manrope(
      fontSize: size,
      color: color,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
    );

final _primaryButton = FilledButton.styleFrom(
  backgroundColor: _blue,
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(48),
);

final _secondaryButton = OutlinedButton.styleFrom(
  foregroundColor: _blue,
  minimumSize: const Size.fromHeight(48),
  side: const BorderSide(color: _line),
);
