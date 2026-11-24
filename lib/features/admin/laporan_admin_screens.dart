import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/admin_bottom_navigator.dart';
import '../../widgets/admin_notification_button.dart';
import 'dashboard_admin_screens.dart';
import 'mitra_admin_screens.dart';
import 'notifikasi_admin_screens.dart';
import 'perizinan_admin_screens.dart';
import 'profil_screens.dart';

const _blue = Color(0xFF1D4ED8);
const _ink = Color(0xFF12243A);
const _muted = Color(0xFF667085);
const _page = Color(0xFFF5F7FB);
const _border = Color(0xFFE7EBF2);
const _green = Color(0xFF087457);
const _red = Color(0xFFCB3038);

enum _Period { week, month, year }

extension on _Period {
  String get label => switch (this) {
    _Period.week => 'Minggu',
    _Period.month => 'Bulan',
    _Period.year => 'Tahun',
  };
  String get range => switch (this) {
    _Period.week => '22–28 Sep 2026',
    _Period.month => 'September 2026',
    _Period.year => 'Januari–September 2026',
  };
  String get fileName => switch (this) {
    _Period.week => 'mingguan',
    _Period.month => 'bulanan',
    _Period.year => 'tahunan',
  };
  List<String> get labels => switch (this) {
    _Period.week => ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    _Period.month => ['Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep'],
    _Period.year => [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
    ],
  };
  List<double> get values => switch (this) {
    _Period.week => [141, 142, 143, 143, 145, 147, 148],
    _Period.month => [80, 95, 110, 128, 139, 148],
    _Period.year => [68, 72, 80, 95, 110, 118, 128, 139, 148],
  };
  String get partners => switch (this) {
    _Period.week => '+7 pekan ini',
    _Period.month => '+12 bulan ini',
    _Period.year => '+148 tahun ini',
  };
  String get orders => switch (this) {
    _Period.week => '1.284',
    _Period.month => '4.850',
    _Period.year => '48.510',
  };
  String get tickets => switch (this) {
    _Period.week => '3.620',
    _Period.month => '14.280',
    _Period.year => '142.800',
  };
  String get gmv => switch (this) {
    _Period.week => 'Rp 356,2 Juta',
    _Period.month => 'Rp 1,42 Miliar',
    _Period.year => 'Rp 13,82 Miliar',
  };
  String get growth => switch (this) {
    _Period.week => '+4,2%',
    _Period.month => '+18,4%',
    _Period.year => '+21,6%',
  };
}

class LaporanAdminScreens extends StatefulWidget {
  const LaporanAdminScreens({super.key});

  @override
  State<LaporanAdminScreens> createState() => _LaporanAdminScreensState();
}

class _LaporanAdminScreensState extends State<LaporanAdminScreens> {
  var _period = _Period.month;
  var _exporting = false;

  void _navigate(int index) {
    final page = switch (index) {
      0 => const DashboardAdminScreens(),
      1 => const MitraAdminScreens(),
      2 => const PerizinanAdminScreens(),
      3 => const LaporanAdminScreens(),
      4 => const ProfilAdminScreens(),
      _ => null,
    };
    if (page != null && index != 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
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
        suggestedName: 'laporan-lokatrip-${_period.fileName}-2026.csv',
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
    final rows = [
      ['Laporan LokaTrip Admin', _period.range],
      ['Catatan', 'Data contoh; belum terhubung ke backend'],
      [],
      ['Metrik', 'Nilai'],
      ['Total mitra', '148'],
      ['Wisata aktif', '215'],
      ['Izin aktif', '120'],
      ['Menunggu verifikasi izin', '12'],
      ['Izin hampir habis', '8'],
      ['Izin kedaluwarsa', '3'],
      ['Total pesanan', _period.orders],
      ['Tiket terjual', _period.tickets],
      ['Nilai transaksi bruto', _period.gmv],
      ['Pertumbuhan nilai transaksi', _period.growth],
    ];
    String quote(String value) => '"${value.replaceAll('"', '""')}"';
    return rows
        .map((row) => row.map((field) => quote(field)).join(','))
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
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotifikasiAdminScreens()),
          ),
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
              _periodPicker(),
              const SizedBox(height: 25),
              _section('Ringkasan platform', trailing: _pill(_period.range)),
              const SizedBox(height: 12),
              _metrics(contentWidth),
              const SizedBox(height: 14),
              _gmvCard(),
              const SizedBox(height: 24),
              _analytics(contentWidth),
              const SizedBox(height: 18),
              _transactionDetails(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 15, color: _muted),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Data contoh untuk rancangan laporan; belum terhubung ke backend.',
                      style: GoogleFonts.manrope(fontSize: 11, color: _muted),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _exporting ? null : _export,
                    icon: _exporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined, size: 18),
                    label: Text(
                      _exporting ? 'Menyimpan…' : 'Simpan laporan CSV',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        _period.range,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _muted,
        ),
      ),
    ],
  );

  Widget _periodPicker() => SegmentedButton<_Period>(
    segments: [
      for (final period in _Period.values)
        ButtonSegment(value: period, label: Text(period.label)),
    ],
    selected: {_period},
    onSelectionChanged: (value) => setState(() => _period = value.first),
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

  Widget _metrics(double width) {
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
            '148',
            _period.partners,
            Icons.storefront_outlined,
            _blue,
            positive: true,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _MetricCard(
            'Wisata aktif',
            '215',
            'Destinasi terdaftar',
            Icons.explore_outlined,
            const Color(0xFF1375A8),
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _MetricCard(
            'Izin legal',
            '120',
            'Izin aktif · kepatuhan SLA 94%',
            Icons.verified_outlined,
            _green,
          ),
        ),
        SizedBox(
          width: cardWidth,
          child: _MetricCard(
            'Total pesanan',
            _period.orders,
            'Transaksi lunas',
            Icons.receipt_long_outlined,
            const Color(0xFF1375A8),
          ),
        ),
      ],
    );
  }

  Widget _gmvCard() => Container(
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
                'NILAI TRANSAKSI BRUTO',
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
          _period.gmv,
          style: GoogleFonts.manrope(
            fontSize: 29,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const Divider(color: Colors.white24, height: 18),
        Row(
          children: [
            const Icon(Icons.trending_up, size: 17, color: Color(0xFF9BF4D1)),
            const SizedBox(width: 5),
            Text(
              _period.growth,
              style: GoogleFonts.manrope(
                color: const Color(0xFF9BF4D1),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'dibanding periode sebelumnya',
              style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11),
            ),
            const Spacer(),
            Text(
              '${_period.orders} pesanan',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _analytics(double width) {
    final chart = _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('Pertumbuhan mitra', trailing: _pill(_period.label)),
          const SizedBox(height: 4),
          Text(
            'Jumlah mitra terdaftar · ${_period.range}',
            style: GoogleFonts.manrope(fontSize: 12, color: _muted),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 240,
            child: _GrowthChart(labels: _period.labels, values: _period.values),
          ),
        ],
      ),
    );
    const legal = _LicensePanel();
    if (width < 900) {
      return Column(children: [chart, const SizedBox(height: 14), legal]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: chart),
        const SizedBox(width: 14),
        const Expanded(flex: 5, child: legal),
      ],
    );
  }

  Widget _transactionDetails() => _Panel(
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
                    'Pesanan valid & lunas',
                    _period.orders,
                    _blue,
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _TransactionTile(
                    Icons.confirmation_number_outlined,
                    'Tiket terjual',
                    'Wisatawan nusantara & asing',
                    _period.tickets,
                    const Color(0xFF1375A8),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _TransactionTile(
                    Icons.account_balance_wallet_outlined,
                    'Nilai transaksi bruto',
                    'Take rate rata-rata 12%',
                    _period.gmv,
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
  const _GrowthChart({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) {
    final min = values.reduce((a, b) => a < b ? a : b) - 8;
    final max = values.reduce((a, b) => a > b ? a : b) + 8;
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
                    '${labels[spot.x.toInt()]} · ${spot.y.toInt()} mitra',
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
  const _LicensePanel();

  @override
  Widget build(BuildContext context) => _Panel(
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
              '143 dokumen',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Kepatuhan izin mitra se-Indonesia',
          style: GoogleFonts.manrope(fontSize: 11, color: _muted),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: const LinearProgressIndicator(
            value: 0.84,
            minHeight: 10,
            backgroundColor: Color(0xFFE7EBF2),
            color: _green,
          ),
        ),
        const SizedBox(height: 12),
        const _LicenseLine('Izin aktif', '120', _green),
        const _LicenseLine('Menunggu verifikasi', '12', Color(0xFF1375A8)),
        const _LicenseLine('Hampir habis', '8', Color(0xFF6478C8)),
        const _LicenseLine('Kedaluwarsa', '3', _red),
      ],
    ),
  );
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
