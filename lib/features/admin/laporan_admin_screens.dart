import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/admin_bottom_navigator.dart';
import '../../widgets/admin_notification_button.dart';
import 'laporan_admin_service.dart';

const _blue = Color(0xFF1D4ED8);
const _ink = Color(0xFF12243A);
const _muted = Color(0xFF667085);
const _page = Color(0xFFF5F7FB);
const _border = Color(0xFFE7EBF2);
const _green = Color(0xFF087457);
const _red = Color(0xFFCB3038);

String _number(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => '.',
);
String _rupiah(int value) => 'Rp ${_number(value)}';

class LaporanAdminScreens extends StatefulWidget {
  const LaporanAdminScreens({super.key});

  @override
  State<LaporanAdminScreens> createState() => _LaporanAdminScreensState();
}

class _LaporanAdminScreensState extends State<LaporanAdminScreens> {
  var _period = LaporanPeriode.bulan;
  var _loading = true;
  String? _loadError;
  LaporanAdminData? _data;
  var _exporting = false;
  var _recovering = false;
  var _autoReconciling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
      _data = null;
    });
    try {
      final result = await LaporanAdminData.load(_period);
      if (mounted)
        setState(() {
          _data = result;
          _loading = false;
        });
    } catch (error) {
      if (mounted)
        setState(() {
          _loadError = error.toString();
          _loading = false;
        });
    }
  }

  /// Sinkronkan otomatis semua transaksi Midtrans yang pending ke laporan pembayaran.
  Future<void> _autoReconcile() async {
    setState(() => _autoReconciling = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'midtrans-payment',
        body: {'action': 'admin_reconcile'},
      );
      final result = response.data;
      if (result is Map) {
        final checked = result['checked'] ?? 0;
        final settled = result['settled'] ?? 0;
        final failed = result['failed'] ?? 0;
        final message = failed > 0
            ? '$settled berhasil, $failed gagal diverifikasi dari $checked transaksi Midtrans.'
            : settled == 0
                ? 'Diperiksa $checked transaksi — semua sudah sinkron.'
                : 'Berhasil: $settled dari $checked transaksi Midtrans disinkronkan ke laporan.';
        _message(message);
        await _load();
      } else {
        _message('Sinkronisasi selesai.');
        await _load();
      }
    } catch (error) {
      final details = error is FunctionException ? error.details : null;
      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : 'Sinkronisasi otomatis gagal: $error';
      _message(message);
    } finally {
      if (mounted) setState(() => _autoReconciling = false);
    }
  }

  Future<void> _recoverMidtransPayment() async {
    final orderCode = TextEditingController();
    final midtransOrderId = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pulihkan pembayaran Midtrans'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: orderCode,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Kode pesanan LokaTrip',
                  hintText: 'LT-XXXXXXXX',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: midtransOrderId,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Order ID Midtrans lengkap',
                  hintText: 'LT-XXXXXXXX-xxxxxxxx',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Status dan nominal diverifikasi ke Midtrans sebelum pembayaran disimpan.',
                style: GoogleFonts.manrope(fontSize: 11, color: _muted),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Verifikasi & pulihkan'),
          ),
        ],
      ),
    );
    final code = orderCode.text.trim();
    final midtransId = midtransOrderId.text.trim();
    orderCode.dispose();
    midtransOrderId.dispose();
    if (confirm != true || !mounted) return;
    if (code.isEmpty || midtransId.isEmpty) {
      _message('Kode pesanan dan Order ID Midtrans wajib diisi.');
      return;
    }

    setState(() => _recovering = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'midtrans-payment',
        body: {
          'action': 'admin_recover',
          'kode_pesan': code,
          'midtrans_order_id': midtransId,
        },
      );
      final result = response.data;
      if (result is Map && result['status'] == 'settlement') {
        _message(
          result['already_recorded'] == true
              ? 'Pembayaran itu sudah tercatat di LokaTrip.'
              : 'Pembayaran Midtrans berhasil dipulihkan.',
        );
        await _load();
      } else {
        final message = result is Map && result['error'] is String
            ? result['error'] as String
            : 'Midtrans belum mengonfirmasi pembayaran ini.';
        _message(message);
      }
    } catch (error) {
      final details = error is FunctionException ? error.details : null;
      final message = details is Map && details['error'] is String
          ? details['error'] as String
          : 'Pemulihan pembayaran gagal: $error';
      _message(message);
    } finally {
      if (mounted) setState(() => _recovering = false);
    }
  }

  String get _periodLabel => switch (_period) {
    LaporanPeriode.minggu => 'Minggu',
    LaporanPeriode.bulan => 'Bulan',
    LaporanPeriode.tahun => 'Tahun',
  };

  String get _periodFileName => switch (_period) {
    LaporanPeriode.minggu => 'mingguan',
    LaporanPeriode.bulan => 'bulanan',
    LaporanPeriode.tahun => 'tahunan',
  };

  void _navigate(int index) {
    final route = switch (index) {
      0 => '/admin/dashboard',
      1 => '/admin/mitra',
      2 => '/admin/perizinan',
      3 => '/admin/laporan',
      4 => '/admin/profil',
      _ => null,
    };
    if (route != null && index != 3) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  Future<void> _export() async {
    if (kIsWeb ||
        !{
          TargetPlatform.windows,
          TargetPlatform.macOS,
          TargetPlatform.linux,
        }.contains(defaultTargetPlatform)) {
      _message('Ekspor CSV hanya tersedia di aplikasi desktop.');
      return;
    }
    setState(() => _exporting = true);
    try {
      final location = await getSaveLocation(
        suggestedName: 'laporan-lokatrip-$_periodFileName.csv',
        confirmButtonText: 'Simpan laporan',
        acceptedTypeGroups: const [
          XTypeGroup(label: 'CSV', extensions: ['csv']),
        ],
      );
      if (location != null) {
        await File(
          location.path,
        ).writeAsString(_csv(), encoding: utf8, flush: true);
        if (mounted) _message('Laporan CSV berhasil disimpan.');
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to export report: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) _message('Laporan gagal disimpan. Coba pilih lokasi lain.');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _csv() {
    final data = _data;
    if (data == null) return '';
    final rows = [
      ['Laporan LokaTrip Admin', data.range],
      ['Sumber', 'Supabase'],
      [],
      ['Metrik', 'Nilai'],
      ['Total mitra', '${data.totalMitra}'],
      ['Wisata aktif', '${data.wisataAktif}'],
      ['Total dokumen izin', '${data.totalDokumen}'],
      ['Izin aktif', '${data.izinAktif}'],
      ['Menunggu verifikasi izin', '${data.izinMenunggu}'],
      ['Izin hampir habis', '${data.izinHampirHabis}'],
      ['Izin kedaluwarsa', '${data.izinKedaluwarsa}'],
      ['Transaksi lunas', '${data.pesananLunas}'],
      ['Tiket terjual', '${data.tiketTerjual}'],
      ['Nilai transaksi bruto', '${data.nilaiTransaksi}'],
      ['Pendapatan biaya layanan', '${data.keuntungan}'],
    ];
    String quote(String value) => '"${value.replaceAll('"', '""')}"';
    return rows
        .map((row) => row.map((field) => quote(field.toString())).join(','))
        .join('\r\n');
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _page,
    body: SafeArea(
      child: Column(
        children: [
          _header(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 1100;
                final contentWidth = constraints.maxWidth - (desktop ? 220 : 0);
                return Row(
                  children: [
                    if (desktop) _sidebar(),
                    Expanded(child: _content(desktop, contentWidth)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: MediaQuery.sizeOf(context).width < 1100
        ? AdminBottomNavigator(currentIndex: 3, onTap: _navigate)
        : null,
  );

  Widget _header() => Container(
    height: 66,
    padding: const EdgeInsets.symmetric(horizontal: 28),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: _border)),
    ),
    child: Row(
      children: [
        Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 22),
        const SizedBox(width: 10),
        Text(
          'LOKATRIP ADMIN',
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: _blue,
          ),
        ),
        const Spacer(),
        AdminNotificationButton(
          onPressed: () => Navigator.pushNamed(context, '/admin/notifikasi'),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFFE8EEFF),
          child: Icon(Icons.person_outline, size: 19, color: _blue),
        ),
      ],
    ),
  );

  Widget _sidebar() => Container(
    width: 220,
    padding: const EdgeInsets.fromLTRB(14, 24, 14, 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: _border)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: Text(
            'ADMINISTRASI',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: _muted,
            ),
          ),
        ),
        _navItem('Dashboard', Icons.dashboard_outlined, 0),
        _navItem('Mitra', Icons.storefront_outlined, 1),
        _navItem('Laporan', Icons.bar_chart_rounded, 3, selected: true),
        _navItem('Profil', Icons.person_outline, 4),
      ],
    ),
  );

  Widget _navItem(
    String label,
    IconData icon,
    int index, {
    bool selected = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Material(
      color: selected ? const Color(0xFFEAF0FF) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _navigate(index),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 19, color: selected ? _blue : _muted),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? _blue : _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _content(bool desktop, double width) {
    final data = _data;
    final contentWidth = (width > 1320 ? 1320.0 : width) - (desktop ? 72 : 48);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        desktop ? 36 : 24,
        28,
        desktop ? 36 : 24,
        32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(desktop),
              const SizedBox(height: 22),
              Row(
                children: [
                  _periodPicker(),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Muat ulang laporan',
                    onPressed: _loading ? null : _load,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              if (_loading) const LinearProgressIndicator(),
              if (_loadError != null) _errorPanel(),
              if (data != null) ...[
                _section('Ringkasan platform', trailing: _pill(data.range)),
                const SizedBox(height: 12),
                _metrics(contentWidth, data),
                const SizedBox(height: 14),
                _gmvCard(data),
                const SizedBox(height: 24),
                _analytics(contentWidth, data),
                const SizedBox(height: 18),
                _transactionDetails(data),
                const SizedBox(height: 18),
                _recentPayments(data),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 15, color: _muted),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        data.midtransSyncWarning ??
                            'Midtrans diperiksa: ${data.midtransChecked}; ${data.midtransSettled} disinkronkan. Terbaru: ${data.midtransLatestOrderCode ?? 'tidak ditemukan'} (${data.midtransLatestStatus ?? 'tidak ada'}).',
                        style: GoogleFonts.manrope(fontSize: 11, color: _muted),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _exporting || _loading ? null : _export,
                      icon: _exporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_outlined, size: 18),
                      label: Text(
                        _exporting ? 'Menyimpan...' : 'Simpan laporan CSV',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentPayments(LaporanAdminData data) {
    final controls = <Widget>[
      _pill('${data.pembayaranTerbaru.length} terbaru'),
      // Tombol auto-sync: sinkronkan semua transaksi Midtrans pending
      TextButton.icon(
        onPressed: _autoReconciling || _loading ? null : _autoReconcile,
        icon: _autoReconciling
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_sync_rounded, size: 16),
        label: Text(_autoReconciling ? 'Menyinkronkan...' : 'Sync Midtrans'),
      ),
      // Tombol pulihkan manual (fallback jika auto-sync gagal)
      TextButton.icon(
        onPressed: _recovering || _loading ? null : _recoverMidtransPayment,
        icon: _recovering
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.build_circle_outlined, size: 16),
        label: Text(_recovering ? 'Memeriksa...' : 'Pulihkan manual'),
      ),
    ];

    return _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pembayaran terbaru',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(spacing: 2, runSpacing: 0, children: controls),
                ],
              );
            }
            return _section(
              'Pembayaran terbaru',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  controls[0],
                  const SizedBox(width: 8),
                  controls[1],
                  const SizedBox(width: 4),
                  controls[2],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        if (data.pembayaranTerbaru.isEmpty)
          Text(
            'Belum ada pembayaran lunas pada periode ini.',
            style: GoogleFonts.manrope(fontSize: 12, color: _muted),
          )
        else
          for (
            var index = 0;
            index < data.pembayaranTerbaru.length;
            index++
          ) ...[
            if (index > 0) const Divider(height: 18),
            _paymentRow(data.pembayaranTerbaru[index]),
          ],
      ],
    ),
  );
  }

  Widget _paymentRow(LaporanPembayaranRingkas payment) {
    final date = payment.waktu;
    final timestamp =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, color: _green, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.kodePesan,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              Text(
                '$timestamp · ${payment.metode}',
                style: GoogleFonts.manrope(fontSize: 10, color: _muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _rupiah(payment.jumlah),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _errorPanel() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_outlined, color: _red),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Laporan gagal dimuat. Periksa koneksi atau sesi admin, lalu coba lagi.',
            style: GoogleFonts.manrope(fontSize: 12, color: _ink),
          ),
        ),
        TextButton(onPressed: _load, child: const Text('Coba lagi')),
      ],
    ),
  );

  Widget _title(bool desktop) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laporan',
              style: GoogleFonts.manrope(
                fontSize: desktop ? 29 : 25,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            Text(
              'Performa mitra, izin usaha, dan transaksi platform',
              style: GoogleFonts.manrope(fontSize: 13, color: _muted),
            ),
          ],
        ),
      ),
      Text(
        _data?.range ?? '',
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _muted,
        ),
      ),
    ],
  );

  Widget _periodPicker() => SegmentedButton<LaporanPeriode>(
    segments: [
      for (final period in LaporanPeriode.values)
        ButtonSegment(
          value: period,
          label: Text(switch (period) {
            LaporanPeriode.minggu => 'Minggu',
            LaporanPeriode.bulan => 'Bulan',
            LaporanPeriode.tahun => 'Tahun',
          }),
        ),
    ],
    selected: {_period},
    onSelectionChanged: (value) {
      setState(() => _period = value.first);
      _load();
    },
    showSelectedIcon: false,
    style: SegmentedButton.styleFrom(
      selectedBackgroundColor: _blue,
      selectedForegroundColor: Colors.white,
    ),
  );

  Widget _section(String title, {Widget? trailing}) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ),
      ?trailing,
    ],
  );

  Widget _pill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF0FF),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: GoogleFonts.manrope(
        color: _blue,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _metrics(double width, LaporanAdminData data) {
    final columns = width >= 1050
        ? 4
        : width >= 650
        ? 2
        : 1;
    final cardWidth = (width - 12 * (columns - 1)) / columns;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: cardWidth,
          child: _MetricCard(
            'Total mitra',
            _number(data.totalMitra),
            'Mitra terdaftar',
            Icons.storefront_outlined,
            _blue,
            positive: true,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _MetricCard(
            'Wisata aktif',
            _number(data.wisataAktif),
            'Destinasi terdaftar',
            Icons.explore_outlined,
            const Color(0xFF1375A8),
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _MetricCard(
            'Izin legal',
            _number(data.izinAktif),
            '${_number(data.izinMenunggu)} menunggu, ${_number(data.izinKedaluwarsa)} kedaluwarsa',
            Icons.verified_outlined,
            _green,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _MetricCard(
            'Pembayaran berhasil',
            _number(data.pesananLunas),
            'Transaksi lunas dalam periode ini',
            Icons.receipt_long_outlined,
            const Color(0xFF1375A8),
          ),
        ),
      ],
    );
  }

  Widget _gmvCard(LaporanAdminData data) {
    final previous = data.keuntunganSebelumnya;
    final change = previous == 0
        ? null
        : (data.keuntungan - previous) / previous * 100;
    // Hitung porsi mitra = nilaiTransaksi - keuntungan (biaya layanan admin)
    final porsiMitra = data.nilaiTransaksi - data.keuntungan;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'KEUNTUNGAN PLATFORM',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: Colors.white70,
                  ),
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
              ),
            ],
          ),
          Text(
            _rupiah(data.keuntungan),
            style: GoogleFonts.manrope(
              fontSize: 29,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Biaya layanan platform dari pembayaran lunas',
            style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11),
          ),
          const Divider(color: Colors.white24, height: 18),
          // Split pendapatan
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PORSI MITRA',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white54,
                      ),
                    ),
                    Text(
                      _rupiah(porsiMitra < 0 ? 0 : porsiMitra),
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF9BF4D1),
                      ),
                    ),
                    Text(
                      'Harga tiket (setelah diskon)',
                      style: GoogleFonts.manrope(fontSize: 9, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 14),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PORSI ADMIN',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white54,
                      ),
                    ),
                    Text(
                      _rupiah(data.keuntungan),
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Biaya layanan platform',
                      style: GoogleFonts.manrope(fontSize: 9, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 18),
          Row(
            children: [
              Icon(
                change == null || change >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                size: 17,
                color: const Color(0xFF9BF4D1),
              ),
              const SizedBox(width: 5),
              Text(
                change == null
                    ? 'Belum ada pembanding'
                    : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% dibanding periode sebelumnya',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF9BF4D1),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${_number(data.pesananLunas)} pembayaran lunas',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nilai transaksi bruto: ${_rupiah(data.nilaiTransaksi)}',
            style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _analytics(double width, LaporanAdminData data) {
    final chart = _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section(
            'Pembayaran lunas dari waktu ke waktu',
            trailing: _pill(_periodLabel),
          ),
          const SizedBox(height: 4),
          Text(
            'Jumlah pembayaran lunas - ${data.range}',
            style: GoogleFonts.manrope(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 240,
            child: _GrowthChart(
              labels: data.chartLabels,
              values: data.chartOrders,
              valueSuffix: 'pembayaran',
            ),
          ),
        ],
      ),
    );
    final legal = _LicensePanel(data: data);
    if (width < 900)
      return Column(children: [chart, const SizedBox(height: 14), legal]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: chart),
        const SizedBox(width: 14),
        Expanded(flex: 5, child: legal),
      ],
    );
  }

  Widget _transactionDetails(LaporanAdminData data) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section('Statistik transaksi'),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 760 ? 3 : 1;
            final gap = 10.0;
            final tileWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: _TransactionTile(
                    Icons.receipt_long_outlined,
                    'Total transaksi',
                    'Pembayaran berhasil',
                    _number(data.pesananLunas),
                    _blue,
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _TransactionTile(
                    Icons.confirmation_number_outlined,
                    'Tiket terjual',
                    'Wisatawan nusantara & asing',
                    _number(data.tiketTerjual),
                    const Color(0xFF1375A8),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _TransactionTile(
                    Icons.account_balance_wallet_outlined,
                    'Pendapatan biaya layanan',
                    'Dari pembayaran lunas',
                    _rupiah(data.keuntungan),
                    _green,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  final String label, value, detail;
  final IconData icon;
  final Color color;
  final bool positive;

  const _MetricCard(
    this.label,
    this.value,
    this.detail,
    this.icon,
    this.color, {
    this.positive = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 125),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                ),
              ),
            ),
            Icon(icon, size: 19, color: color),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        Row(
          children: [
            if (positive)
              const Icon(Icons.trending_up, size: 14, color: _green),
            Expanded(
              child: Text(
                detail,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: positive ? _green : _muted,
                  fontWeight: positive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: _border),
    ),
    child: child,
  );
}

class _GrowthChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final String valueSuffix;
  const _GrowthChart({
    required this.labels,
    required this.values,
    required this.valueSuffix,
  });

  @override
  Widget build(BuildContext context) {
    // Guard: jika semua nilai 0 / sama, beri rentang minimal agar chart tidak crash.
    final rawMin = values.reduce((a, b) => a < b ? a : b);
    final rawMax = values.reduce((a, b) => a > b ? a : b);
    final min = rawMin - 8;
    final max = rawMax == rawMin ? rawMin + 16 : rawMax + 8;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        minY: min,
        maxY: max,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: ((max - min) / 4)
              .clamp(1, double.infinity)
              .toDouble(),
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: _border, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    labels[index],
                    style: GoogleFonts.manrope(fontSize: 10, color: _muted),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    '${labels[spot.x.toInt()]} · ${spot.y.toInt()} $valueSuffix',
                    GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            color: _blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: _blue.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 220),
    );
  }
}

class _LicensePanel extends StatelessWidget {
  const _LicensePanel({required this.data});
  final LaporanAdminData data;

  @override
  Widget build(BuildContext context) {
    final total = data.totalDokumen;
    final compliance = total == 0 ? 0.0 : data.izinAktif / total;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_outlined, color: _green),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Status legalitas & izin',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
              Text(
                '${_number(total)} dokumen',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Status dokumen mitra di database',
            style: GoogleFonts.manrope(fontSize: 11, color: _muted),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: compliance,
              minHeight: 10,
              backgroundColor: const Color(0xFFE7EBF2),
              color: _green,
            ),
          ),
          const SizedBox(height: 12),
          _LicenseLine('Izin aktif', _number(data.izinAktif), _green),
          _LicenseLine(
            'Menunggu verifikasi',
            _number(data.izinMenunggu),
            const Color(0xFF1375A8),
          ),
          _LicenseLine(
            'Hampir habis (30 hari)',
            _number(data.izinHampirHabis),
            const Color(0xFF6478C8),
          ),
          _LicenseLine('Kedaluwarsa', _number(data.izinKedaluwarsa), _red),
        ],
      ),
    );
  }
}

class _LicenseLine extends StatelessWidget {
  final String label, value;
  final Color color;
  const _LicenseLine(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(value, style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _TransactionTile extends StatelessWidget {
  final IconData icon;
  final String title, detail, value;
  final Color color;
  const _TransactionTile(
    this.icon,
    this.title,
    this.detail,
    this.value,
    this.color,
  );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5FC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              Text(
                detail,
                style: GoogleFonts.manrope(fontSize: 10, color: _muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
        ),
      ],
    ),
  );
}
