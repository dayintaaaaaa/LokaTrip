import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _blue = Color(0xFF1749C8);
const _ink = Color(0xFF12243A);
const _muted = Color(0xFF697386);
const _page = Color(0xFFF5F7FC);
const _line = Color(0xFFE5EAF3);
const _paleBlue = Color(0xFFEDF3FF);
const _green = Color(0xFF087457);
const _red = Color(0xFFCB3038);

enum StatusAuditMitra { menunggu, aktif, ditolak }

class VerifikasiMitraAdminScreens extends StatefulWidget {
  final String id;
  final String partner;
  final String destination;
  final String category;
  final String dates;
  final String auditor;
  final String note;
  final StatusAuditMitra status;
  final int rejectedStep;
  final ValueChanged<int> onApproved;
  final ValueChanged<int> onRejected;
  final VoidCallback onRevision;

  const VerifikasiMitraAdminScreens({
    super.key,
    required this.id,
    required this.partner,
    required this.destination,
    required this.category,
    required this.dates,
    required this.auditor,
    required this.note,
    required this.status,
    required this.rejectedStep,
    required this.onApproved,
    required this.onRejected,
    required this.onRevision,
  });

  @override
  State<VerifikasiMitraAdminScreens> createState() =>
      _VerifikasiMitraAdminScreensState();
}

class _VerifikasiMitraAdminScreensState
    extends State<VerifikasiMitraAdminScreens> {
  static const _steps = ['Data', 'Dokumen', 'Wisata', 'Keputusan'];
  late StatusAuditMitra _status = widget.status;
  late int _rejectedStep = widget.rejectedStep;
  late int _step = switch (widget.status) {
    StatusAuditMitra.menunggu => 0,
    StatusAuditMitra.aktif => 3,
    StatusAuditMitra.ditolak => widget.rejectedStep - 1,
  };

  void _revise() {
    setState(() {
      _status = StatusAuditMitra.menunggu;
      _rejectedStep = 0;
      _step = 0;
    });
    widget.onRevision();
    _message('Permintaan revisi dicatat. Audit dimulai kembali dari Data.');
  }

  void _reject() {
    final rejectedAt = _step + 1;
    setState(() {
      _status = StatusAuditMitra.ditolak;
      _rejectedStep = rejectedAt;
    });
    widget.onRejected(rejectedAt);
    _message('Pengajuan ditolak pada tahap ${_steps[_step]}.');
  }

  void _approve() {
    setState(() {
      _status = StatusAuditMitra.aktif;
      _rejectedStep = 0;
      _step = 3;
    });
    widget.onApproved(4);
    _message('Izin diterbitkan dan mitra diaktifkan.');
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _page,
    body: SafeArea(
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final pad = wide ? 32.0 : 18.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(pad),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _queueCard(),
                          const SizedBox(height: 14),
                          _progressCard(wide),
                          const SizedBox(height: 18),
                          if (wide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _stageCard()),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _partnerCard()),
                              ],
                            )
                          else ...[
                            _partnerCard(),
                            const SizedBox(height: 14),
                            _stageCard(),
                          ],
                          const SizedBox(height: 16),
                          _actions(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

  Widget _header(BuildContext context) => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 18),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: _line)),
    ),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Kembali ke Perizinan',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: _ink),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Verifikasi mitra',
            style: GoogleFonts.manrope(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (MediaQuery.sizeOf(context).width > 650)
          Text(
            'Audit perizinan',
            style: GoogleFonts.manrope(color: _muted, fontSize: 12),
          ),
      ],
    ),
  );

  Widget _queueCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        const Icon(Icons.confirmation_number_outlined, color: _blue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.id,
            style: GoogleFonts.manrope(
              color: _blue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _tag(
          _status == StatusAuditMitra.aktif
              ? 'IZIN AKTIF'
              : _status == StatusAuditMitra.ditolak
              ? 'DITOLAK'
              : 'MENUNGGU AUDIT',
          _status == StatusAuditMitra.aktif
              ? _green
              : _status == StatusAuditMitra.ditolak
              ? _red
              : _blue,
        ),
      ],
    ),
  );

  Widget _progressCard(bool wide) => Container(
    padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 12, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          Expanded(child: _stepMarker(i)),
          if (i < _steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 21),
                color: _stepPassed(i) ? _blue : _line,
              ),
            ),
        ],
      ],
    ),
  );

  bool _stepPassed(int index) =>
      _status == StatusAuditMitra.aktif ||
      (_status == StatusAuditMitra.menunggu && index < _step) ||
      (_status == StatusAuditMitra.ditolak && index < _rejectedStep - 1);

  Widget _stepMarker(int index) {
    final rejected =
        _status == StatusAuditMitra.ditolak && index == _rejectedStep - 1;
    final passed = _stepPassed(index);
    final current = !rejected && !passed && index == _step;
    final color = rejected
        ? _red
        : passed || current
        ? _blue
        : const Color(0xFFDCE5F5);
    return Column(
      children: [
        Semantics(
          label: rejected
              ? 'Tahap ${index + 1} ${_steps[index]}, ditolak'
              : passed
              ? 'Tahap ${index + 1} ${_steps[index]}, selesai'
              : current
              ? 'Tahap ${index + 1} ${_steps[index]}, sedang diperiksa'
              : 'Tahap ${index + 1} ${_steps[index]}, belum dimulai',
          child: CircleAvatar(
            radius: 17,
            backgroundColor: color,
            child: rejected || passed
                ? Icon(
                    rejected ? Icons.close : Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : Text(
                    '${index + 1}',
                    style: GoogleFonts.manrope(
                      color: current ? Colors.white : _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${index + 1}. ${_steps[index]}',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: current || rejected || passed
                ? FontWeight.w800
                : FontWeight.w600,
            color: rejected
                ? _red
                : current || passed
                ? _blue
                : _muted,
          ),
        ),
      ],
    );
  }

  Widget _partnerCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tag('MITRA WISATA', _blue),
        const SizedBox(height: 9),
        Text(
          widget.partner,
          style: GoogleFonts.manrope(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          widget.destination,
          style: GoogleFonts.manrope(color: _muted, fontSize: 13),
        ),
        const Divider(height: 26, color: _line),
        _info('Kategori', widget.category),
        _info('Masa berlaku', widget.dates),
        _info('Auditor', widget.auditor),
        const SizedBox(height: 6),
        Text(
          widget.note,
          style: GoogleFonts.manrope(color: _muted, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _stageCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _stageTitle,
          style: GoogleFonts.manrope(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _stageDescription,
          style: GoogleFonts.manrope(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 16),
        ..._stageRows,
      ],
    ),
  );

  String get _stageTitle => switch (_step) {
    0 => 'Data mitra',
    1 => 'Dokumen legalitas',
    2 => 'Paket wisata & keselamatan',
    _ => 'Keputusan audit',
  };

  String get _stageDescription => switch (_step) {
    0 => 'Periksa kecocokan data usaha dan pengelola.',
    1 => 'Periksa dokumen dan masa berlakunya.',
    2 => 'Pastikan paket dan standar keselamatan sesuai.',
    _ => 'Tentukan hasil akhir pemeriksaan mitra.',
  };

  List<Widget> get _stageRows => switch (_step) {
    0 => [
      _auditRow('Nomor registrasi', widget.id),
      _auditRow('Mitra', widget.partner),
      _auditRow('Destinasi', widget.destination),
      _auditRow('Kategori usaha', widget.category),
    ],
    1 => [
      _documentRow('Dokumen badan usaha'),
      _documentRow('Izin operasional wisata'),
      _documentRow('Asuransi pengunjung'),
      _documentRow('Dokumen pendukung'),
    ],
    2 => [
      _documentRow('Paket wisata dan area operasi'),
      _documentRow('Kendaraan dan standar keselamatan'),
      _documentRow('Pemandu wisata'),
      _documentRow('Asuransi penumpang'),
    ],
    _ => [
      _auditRow('Data mitra', _statusText(0)),
      _auditRow('Dokumen legalitas', _statusText(1)),
      _auditRow('Paket wisata', _statusText(2)),
    ],
  };

  String _statusText(int index) {
    if (_status == StatusAuditMitra.aktif || index < _rejectedStep - 1) {
      return 'Lolos';
    }
    if (_status == StatusAuditMitra.ditolak && index == _rejectedStep - 1) {
      return 'Perlu diperbaiki';
    }
    return 'Menunggu audit';
  }

  Widget _auditRow(String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: _paleBlue,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.manrope(fontSize: 12, color: _ink),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _documentRow(String label) {
    final failedDocument = switch (_rejectedStep) {
      2 => 'Izin operasional wisata',
      3 => 'Kendaraan dan standar keselamatan',
      _ => '',
    };
    final rejected =
        _status == StatusAuditMitra.ditolak &&
        _step + 1 == _rejectedStep &&
        label == failedDocument;
    final passed = _status == StatusAuditMitra.aktif;
    final text = rejected
        ? 'Perlu revisi'
        : passed
        ? 'Terverifikasi'
        : 'Menunggu';
    final color = rejected
        ? _red
        : passed
        ? _green
        : _muted;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: _paleBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            rejected
                ? Icons.error_outline
                : passed
                ? Icons.verified_outlined
                : Icons.schedule,
            color: color,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    final rejected = _status == StatusAuditMitra.ditolak;
    final active = _status == StatusAuditMitra.aktif;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!active && !rejected && _step < 3)
          FilledButton.icon(
            onPressed: () => setState(() => _step++),
            icon: const Icon(Icons.arrow_forward),
            label: Text('Lanjut ke ${_steps[_step + 1]} (Tahap ${_step + 2})'),
            style: _primaryButton,
          ),
        if (!active && _step == 3)
          FilledButton.icon(
            onPressed: _approve,
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Terbitkan izin & aktifkan mitra'),
            style: _primaryButton,
          ),
        if (!active && !rejected && _step == 1) ...[
          const SizedBox(height: 9),
          OutlinedButton.icon(
            onPressed: _reject,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Tolak pengajuan'),
            style: OutlinedButton.styleFrom(foregroundColor: _red),
          ),
        ],
        if (!active && !rejected && _step == 3) ...[
          const SizedBox(height: 9),
          OutlinedButton.icon(
            onPressed: _reject,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Tolak pengajuan mitra'),
            style: OutlinedButton.styleFrom(foregroundColor: _red),
          ),
        ],
        if (!active && rejected) ...[
          FilledButton.icon(
            onPressed: _revise,
            icon: const Icon(Icons.edit_note),
            label: const Text('Minta perbaikan data'),
            style: _primaryButton,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.maybePop(context),
            child: const Text('Kembali ke daftar perizinan'),
          ),
        ],
        if (active)
          FilledButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Selesai — semua tahap terverifikasi'),
            style: _primaryButton,
          ),
        if (!active && !rejected && _step < 3) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _revise,
            icon: const Icon(Icons.edit_note),
            label: const Text('Minta revisi'),
          ),
        ],
      ],
    );
  }

  Widget _info(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: GoogleFonts.manrope(color: _muted, fontSize: 11),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              color: _ink,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    ),
  );
}

final _primaryButton = FilledButton.styleFrom(
  backgroundColor: _blue,
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(48),
);

Widget _tag(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(99),
  ),
  child: Text(
    label,
    style: GoogleFonts.manrope(
      color: color,
      fontSize: 9,
      fontWeight: FontWeight.w800,
    ),
  ),
);
