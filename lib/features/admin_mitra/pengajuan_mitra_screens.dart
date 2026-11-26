import 'dart:convert';
import 'dart:typed_data';
import '../../core/mitra_theme.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../../core/session_manager.dart';
import '../../widgets/mitra_bottom_navigator.dart';
import '../../widgets/tombol_ai_deskripsi_mitra.dart';
import 'wisata_saya_mitra_screen.dart';

const _blue = MitraPalette.primary;
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
      'child_price',
      'quota',
      'hours',
    ])
      name: TextEditingController(),
  };
  final _documents = <String, String>{};
  final _uploadedDocumentRows = <String, Map<String, dynamic>>{};
  final _previousFilesNeedReupload = <String>[];

  int _step = 0;
  String _category = '';
  List<String> _categories = const [];
  String _photoName = '';
  String _submissionId = '';
  Uint8List? _photo;
  bool _agreed = false;
  bool _loading = true;
  bool _submitting = false;
  bool _uploadingDocuments = false;
  bool _draggingDocuments = false;
  String? _photoMimeType;

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
      final savedDocuments = Map<String, String>.from(
        data['documents'] as Map? ?? {},
      );
      final uploaded = data['uploadedDocumentRows'];
      if (uploaded is Map) {
        for (final entry in uploaded.entries) {
          if (entry.key is String && entry.value is Map) {
            _uploadedDocumentRows[entry.key as String] =
                Map<String, dynamic>.from(entry.value as Map);
          }
        }
      }
      for (final entry in savedDocuments.entries) {
        if (_uploadedDocumentRows.containsKey(entry.key)) {
          _documents[entry.key] = entry.value;
        } else {
          _previousFilesNeedReupload.add(entry.value);
        }
      }
    }
    try {
      _categories = await MitraApi.getKategoriWisata();
      if (!_categories.contains(_category)) {
        _category = _categories.isEmpty ? '' : _categories.first;
      }
    } catch (error) {
      _categories = const [];
      _category = '';
      if (mounted) _message('Kategori wisata gagal dimuat: $error');
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
      'uploadedDocumentRows': _uploadedDocumentRows,
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
        _photoMimeType = _mimeType(file.name);
      });
    } catch (error, stackTrace) {
      debugPrint('Gagal memilih foto wisata: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) _message('Foto tidak dapat dibuka. Pilih file gambar lain.');
    }
  }

  Future<void> _pickPerizinanFiles() async {
    try {
      final files = await openFiles(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Dokumen perizinan',
            extensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
          ),
        ],
      );
      await _uploadPerizinanFiles(files);
    } catch (error, stackTrace) {
      debugPrint('Gagal memilih dokumen perizinan: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) _message('Dokumen tidak dapat dibuka: $error');
    }
  }

  Future<void> _uploadPerizinanFiles(List<XFile> files) async {
    if (files.isEmpty || _uploadingDocuments) return;
    final token = await SessionManager.currentMitraToken();
    if (token == null) {
      if (mounted) {
        _message('Sesi mitra tidak ditemukan. Silakan masuk kembali.');
      }
      return;
    }
    setState(() => _uploadingDocuments = true);
    var uploadedCount = 0;
    try {
      for (final file in files) {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty || bytes.length > 8 * 1024 * 1024) {
          _message('${file.name}: ukuran dokumen maksimal 8 MB.');
          continue;
        }
        final result = await MitraApi.uploadDokumen(
          token: token,
          jenisDokumen: 'Dokumen perizinan',
          nomorDokumen: '',
          fileName: file.name,
          mimeType: _mimeType(file.name),
          bytes: bytes,
        );
        final document = result['document'];
        if (document is! Map<String, dynamic>) {
          throw const ApiException('Data dokumen yang tersimpan tidak valid.');
        }
        final id = document['id_dokumen']?.toString();
        if (id == null || id.isEmpty) {
          throw const ApiException('Supabase tidak mengembalikan ID dokumen.');
        }
        if (!mounted) return;
        setState(() {
          _documents[id] = file.name;
          _uploadedDocumentRows[id] = document;
          _previousFilesNeedReupload.remove(file.name);
        });
        uploadedCount++;
        await _saveDraft();
      }
      if (mounted && uploadedCount > 0) {
        _message('$uploadedCount dokumen perizinan tersimpan di Supabase.');
      }
    } catch (error, stackTrace) {
      debugPrint('Gagal mengunggah dokumen perizinan: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) _message('Unggahan ke Supabase gagal: $error');
    } finally {
      if (mounted) setState(() => _uploadingDocuments = false);
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
      _submissionId = '';
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
    if (_submitting || _uploadingDocuments) return;
    final filesToReselect = _documents.keys
        .where((title) => !_uploadedDocumentRows.containsKey(title))
        .toList(growable: false);
    if (filesToReselect.isNotEmpty) {
      _message(
        'Unggah ulang berkas ${filesToReselect.join(', ')} agar tersimpan di Supabase.',
      );
      return;
    }
    final token = await SessionManager.currentMitraToken();
    if (token == null) {
      _message('Sesi mitra tidak ditemukan. Silakan masuk kembali.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final result = await MitraApi.submitPengajuan(
        token: token,
        values: {
          'nama_wisata': _value('destination'),
          'deskripsi': _value('description'),
          'kategori': _category,
          'lokasi': _value('location'),
          'nama_paket': _value('ticket'),
          'harga': _value('price').replaceAll('.', ''),
          'harga_anak': _value('child_price').replaceAll('.', ''),
          'kuota': int.tryParse(_value('quota').replaceAll('.', '')) ?? 0,
          'jam_operasional': _value('hours'),
        },
        fotoName: _photoName.isEmpty ? null : _photoName,
        fotoMimeType: _photoMimeType,
        fotoBytes: _photo,
        dokumen: const [],
      );
      await _clearDraft();
      if (!mounted) return;
      final application = result['application'];
      final idWisata = application is Map ? application['id_wisata'] : null;
      _message(
        'Pengajuan berhasil dikirim${idWisata == null ? '' : ' (ID wisata $idWisata)'}. Status menunggu verifikasi admin.',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const WisataSayaMitraScreen()),
      );
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _clearDraft() async {
    await (await SharedPreferences.getInstance()).remove(_draftKey);
    _documents.clear();
    _uploadedDocumentRows.clear();
  }

  String _mimeType(String name) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: mitraTheme(Theme.of(context)),
    child: Scaffold(
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
          TombolAiDeskripsiMitra(
            ambilData: () => {
              'nama_wisata': _value('destination'),
              'kategori': _category,
              'lokasi': _value('location'),
              'jam_operasional': _value('hours'),
              'deskripsi_saat_ini': _value('description'),
            },
            onPakai: (teks) {
              _fields['description']!.text = teks;
              _changed();
            },
          ),
          _label('Kategori wisata'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: _decoration(),
            hint: Text(
              _categories.isEmpty
                  ? 'Kategori belum tersedia'
                  : 'Pilih kategori wisata',
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Pilih kategori wisata.' : null,
            items: _categories
                .map(
                  (item) => DropdownMenuItem(value: item, child: Text(item)),
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
            'Harga tiket dewasa (Rp)',
            required: true,
            keyboard: TextInputType.number,
          ),
          _field(
            'child_price',
            'Harga tiket anak (3-12 tahun) (Rp)',
            required: true,
            hint: 'Masukkan 0 jika gratis',
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
        'Tahap 3: Dokumen perizinan',
        'Unggah semua berkas perizinan sekaligus. Admin akan memeriksanya.',
      ),
      const SizedBox(height: 14),
      _perizinanDropZone(),
      if (_documents.isNotEmpty) ...[
        const SizedBox(height: 12),
        _panel('Berkas tersimpan', Icons.cloud_done_outlined, [
          for (final entry in _documents.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: _green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.value, style: _textStyle(12))),
                  Text(
                    'Tersimpan',
                    style: _textStyle(10, color: _green, bold: true),
                  ),
                ],
              ),
            ),
        ]),
      ],
      if (_previousFilesNeedReupload.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          'Berkas dari draft lama belum tersimpan online: ${_previousFilesNeedReupload.join(', ')}. Unggah kembali jika masih diperlukan.',
          style: _textStyle(11, color: const Color(0xFFB45309)),
        ),
      ],
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
        'Berkas yang dipilih langsung tersimpan privat di Supabase.',
        style: _textStyle(11, color: _muted),
      ),
    ],
  );

  Widget _perizinanDropZone() => DropTarget(
    onDragEntered: (_) => setState(() => _draggingDocuments = true),
    onDragExited: (_) => setState(() => _draggingDocuments = false),
    onDragDone: (details) {
      setState(() => _draggingDocuments = false);
      _uploadPerizinanFiles(details.files);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _draggingDocuments ? const Color(0xFFE4EDFF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _draggingDocuments ? _blue : _line,
          width: _draggingDocuments ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _draggingDocuments
                ? Icons.move_to_inbox_outlined
                : Icons.cloud_upload_outlined,
            size: 36,
            color: _blue,
          ),
          const SizedBox(height: 9),
          Text(
            _draggingDocuments
                ? 'Lepaskan dokumen di sini'
                : 'Seret dan lepas semua dokumen perizinan',
            textAlign: TextAlign.center,
            style: _textStyle(14, bold: true),
          ),
          const SizedBox(height: 5),
          Text(
            'PDF, JPG, PNG, atau WEBP • Maksimal 8 MB per file',
            textAlign: TextAlign.center,
            style: _textStyle(11, color: _muted),
          ),
          const SizedBox(height: 13),
          OutlinedButton.icon(
            onPressed: _uploadingDocuments ? null : _pickPerizinanFiles,
            icon: _uploadingDocuments
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.attach_file),
            label: Text(
              _uploadingDocuments
                  ? 'Mengunggah dokumen…'
                  : 'Pilih beberapa file',
            ),
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
            _tag('PENGAJUAN MITRA', color: const Color(0xFF9FF4D2)),
            const SizedBox(height: 10),
            Text(
              'Nomor pengajuan',
              style: _textStyle(12, color: Colors.white70),
            ),
            Text(
              'Dibuat saat dikirim',
              style: _textStyle(18, bold: true, color: Colors.white),
            ),
            Text(
              'Status: Siap dikirim ke admin',
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
        _summary('Harga dewasa', 'Rp ${_value('price')} / orang'),
        _summary('Harga anak (3-12 tahun)', 'Rp ${_value('child_price')} / orang'),
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
        'Berkas perizinan tersimpan di Supabase. Data wisata dikirim saat pengajuan dikirim.',
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
              onPressed: _submitting
                  ? null
                  : _step == 3
                  ? _submitAndGoToWisataSaya
                  : _next,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _step == 3
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward,
                    ),
              label: Text(
                _submitting
                    ? 'Mengirim pengajuan…'
                    : switch (_step) {
                        0 => 'Lanjut ke Tahap 2: Tiket & Kuota',
                        1 => 'Lanjut ke Tahap 3: Legalitas',
                        2 => 'Siapkan Pengajuan Tahap 4',
                        _ => 'Kirim Pengajuan',
                      },
                textAlign: TextAlign.center,
              ),
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
