import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/mitra_theme.dart';

import '../../core/api_client.dart';
import '../../core/format_tanggal.dart';
import '../../core/session_manager.dart';
import '../../widgets/mitra_bottom_navigator.dart';

class LegalitasMitraScreen extends StatefulWidget {
  const LegalitasMitraScreen({super.key});

  @override
  State<LegalitasMitraScreen> createState() => _LegalitasMitraScreenState();
}

class _LegalitasMitraScreenState extends State<LegalitasMitraScreen> {
  bool _loading = true;
  String? _error;
  int _filter = 0;
  List<Map<String, dynamic>> _documents = const [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await SessionManager.currentMitraToken();
      if (token == null) {
        throw const ApiException(
          'Sesi mitra tidak ditemukan. Silakan masuk kembali.',
        );
      }
      final documents = await MitraApi.dokumen(token);
      if (!mounted) return;
      setState(() => _documents = documents);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _visibleDocuments => _documents
      .where((item) {
        final status = item['status_approve']?.toString().toUpperCase();
        return switch (_filter) {
          1 => status != 'Y',
          2 => status == 'Y',
          _ => true,
        };
      })
      .toList(growable: false);

  int get _approvedCount => _documents
      .where((item) => item['status_approve']?.toString().toUpperCase() == 'Y')
      .length;

  String _status(Map<String, dynamic> document) =>
      switch (document['status_approve']?.toString().toUpperCase()) {
        'Y' => 'Disetujui',
        'R' => 'Perlu revisi',
        'N' => 'Menunggu pemeriksaan',
        _ => 'Belum ditentukan',
      };

  String _formatExpiry(String? value) {
    if (value == null || value.trim().isEmpty) return 'Belum dicantumkan';
    final date = DateTime.tryParse(value);
    return date == null ? value : formatTanggal(date.toLocal());
  }

  Color _statusColor(Map<String, dynamic> document) =>
      switch (document['status_approve']?.toString().toUpperCase()) {
        'Y' => const Color(0xFF15803D),
        'R' => const Color(0xFFB91C1C),
        _ => const Color(0xFFB45309),
      };

  bool _uploading = false;
  bool _dragging = false;

  Future<void> _pickDocuments() async {
    try {
      final files = await openFiles(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Dokumen perizinan',
            extensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
          ),
        ],
      );
      await _uploadDocuments(files);
    } catch (error) {
      _message('Dokumen tidak dapat dibuka: $error');
    }
  }

  Future<void> _uploadDocuments(List<XFile> files) async {
    if (files.isEmpty || _uploading) return;
    final token = await SessionManager.currentMitraToken();
    if (token == null) {
      _message('Sesi mitra tidak ditemukan. Silakan masuk kembali.');
      return;
    }
    setState(() => _uploading = true);
    var uploaded = 0;
    try {
      for (final file in files) {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty || bytes.length > 8 * 1024 * 1024) {
          _message('${file.name}: ukuran dokumen maksimal 8 MB.');
          continue;
        }
        await MitraApi.uploadDokumen(
          token: token,
          jenisDokumen: 'Dokumen perizinan',
          nomorDokumen: '',
          fileName: file.name,
          mimeType: _mimeType(file.name),
          bytes: bytes,
        );
        uploaded++;
      }
      if (uploaded > 0) {
        await _loadDocuments();
        if (mounted) _message('$uploaded dokumen tersimpan di Supabase.');
      }
    } catch (error) {
      if (mounted) _message('Unggahan ke Supabase gagal: $error');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Widget _uploadDropZone() => DropTarget(
    onDragEntered: (_) => setState(() => _dragging = true),
    onDragExited: (_) => setState(() => _dragging = false),
    onDragDone: (details) {
      setState(() => _dragging = false);
      _uploadDocuments(details.files);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _dragging ? const Color(0xFFE4EDFF) : MitraPalette.canvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _dragging ? MitraPalette.primary : const Color(0xFFCBD5E1),
          width: _dragging ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _dragging
                ? Icons.move_to_inbox_outlined
                : Icons.cloud_upload_outlined,
            size: 32,
            color: MitraPalette.primary,
          ),
          const SizedBox(height: 8),
          Text(
            _dragging
                ? 'Lepaskan dokumen di sini'
                : 'Seret semua dokumen perizinan ke sini',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PDF, JPG, PNG, atau WEBP • Maksimal 8 MB per file',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 11, color: MitraPalette.muted),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _uploading ? null : _pickDocuments,
            icon: _uploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.attach_file),
            label: Text(_uploading ? 'Mengunggah…' : 'Pilih beberapa file'),
          ),
        ],
      ),
    ),
  );
  String _mimeType(String name) => switch (name.split('.').last.toLowerCase()) {
    'pdf' => 'application/pdf',
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final compliance = _documents.isEmpty
        ? 0.0
        : _approvedCount / _documents.length;
    return Theme(
      data: mitraTheme(Theme.of(context)),
      child: Scaffold(
        backgroundColor: MitraPalette.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: MitraPalette.line)),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/LokaTrip-logo-no-van.png',
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Legalitas Mitra',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _loading ? null : _loadDocuments,
                      tooltip: 'Muat ulang',
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    IconButton.filledTonal(
                      onPressed: _uploading ? null : _pickDocuments,
                      tooltip: 'Unggah dokumen',
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? _messageState(
                        Icons.cloud_off_outlined,
                        'Dokumen belum dapat dimuat',
                        _error!,
                        action: true,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDocuments,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                          children: [
                            Text(
                              'Pusat Legalitas & Kepatuhan',
                              style: GoogleFonts.manrope(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: MitraPalette.ink,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Pantau dokumen yang sudah dikirim dan tindak lanjut pemeriksaan admin.',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: MitraPalette.muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _uploadDropZone(),
                            const SizedBox(height: 16),
                            _complianceCard(compliance),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _filterChip('Semua (${_documents.length})', 0),
                                const SizedBox(width: 8),
                                _filterChip(
                                  'Perlu tindakan (${_documents.length - _approvedCount})',
                                  1,
                                ),
                                const SizedBox(width: 8),
                                _filterChip('Disetujui ($_approvedCount)', 2),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_visibleDocuments.isEmpty)
                              _messageState(
                                Icons.folder_open_outlined,
                                _documents.isEmpty
                                    ? 'Belum ada dokumen legalitas'
                                    : 'Tidak ada dokumen pada filter ini',
                                _documents.isEmpty
                                    ? 'Unggah seluruh berkas perizinan sekaligus. Status dan catatan pemeriksaan admin tampil di halaman ini.'
                                    : 'Coba pilih filter lain untuk melihat dokumen mitra.',
                              )
                            else ...[
                              for (final document in _visibleDocuments) ...[
                                _documentCard(document),
                                const SizedBox(height: 12),
                              ],
                            ],
                            const SizedBox(height: 10),
                            _secureNote(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const MitraBottomNavigator(currentIndex: 2),
      ),
    );
  }

  Widget _complianceCard(double compliance) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: MitraPalette.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: MitraPalette.primary,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Kelengkapan dokumen',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${(compliance * 100).round()}%',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: MitraPalette.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: compliance,
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
          backgroundColor: MitraPalette.line,
          color: const Color(0xFF15803D),
        ),
        const SizedBox(height: 8),
        Text(
          _documents.isEmpty
              ? 'Belum ada dokumen yang dikirim.'
              : '$_approvedCount dari ${_documents.length} dokumen telah disetujui.',
          style: GoogleFonts.manrope(fontSize: 11, color: MitraPalette.muted),
        ),
      ],
    ),
  );

  Widget _filterChip(String label, int value) => Expanded(
    child: ChoiceChip(
      label: SizedBox(
        width: double.infinity,
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
      labelStyle: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      selectedColor: MitraPalette.primaryLight,
      side: BorderSide(
        color: _filter == value
            ? MitraPalette.primaryBorder
            : MitraPalette.line,
      ),
    ),
  );

  Widget _messageState(
    IconData icon,
    String title,
    String message, {
    bool action = false,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: MitraPalette.muted),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(fontSize: 12, color: MitraPalette.muted),
          ),
          if (action) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadDocuments,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _secureNote() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: MitraPalette.primaryLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lock_outline, size: 17, color: MitraPalette.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Berkas disimpan privat. Tautan unduh hanya berlaku sementara dan pemeriksaan dilakukan oleh admin LokaTrip.',
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _documentCard(Map<String, dynamic> document) {
    final type = (document['jenis_dokumen'] as String?)?.trim();
    final number = (document['nomor_dokumen'] as String?)?.trim();
    final file = (document['nama_berkas'] as String?)?.trim();
    final expiry = document['masa_berlaku_sampai']?.toString();
    final note = (document['catatan_admin'] as String?)?.trim();
    final reviewed = document['diperiksa_pada']?.toString();
    final color = _statusColor(document);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MitraPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.description_outlined,
                color: MitraPalette.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  type?.isNotEmpty == true ? type! : 'Dokumen legalitas',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _status(document),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow(
            'Nomor dokumen',
            number?.isNotEmpty == true ? number! : 'Belum dicantumkan',
          ),
          _detailRow(
            'Berkas',
            file?.isNotEmpty == true ? file! : 'Berkas tersimpan',
          ),
          _detailRow('Berlaku sampai', _formatExpiry(expiry)),
          if (reviewed?.isNotEmpty == true) _detailRow('Diperiksa', reviewed!),
          if (note?.isNotEmpty == true) ...[
            const Divider(height: 20),
            Text(
              'Catatan admin',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: MitraPalette.muted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              note!,
              style: GoogleFonts.manrope(fontSize: 12, color: MitraPalette.ink),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.manrope(fontSize: 11, color: MitraPalette.muted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    ),
  );
}
