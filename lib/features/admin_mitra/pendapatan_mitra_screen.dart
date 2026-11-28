import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/mitra_theme.dart';
import '../../widgets/mitra_bottom_navigator.dart';

/// Halaman laporan pendapatan mitra — grafik mingguan/bulanan/tahunan dari DB real.
class PendapatanMitraScreen extends StatefulWidget {
  const PendapatanMitraScreen({super.key});

  @override
  State<PendapatanMitraScreen> createState() => _PendapatanMitraScreenState();
}

enum _Periode { minggu, bulan, tahun }

class _PendapatanMitraScreenState extends State<PendapatanMitraScreen> {
  _Periode _periode = _Periode.bulan;
  bool _loading = true;
  String? _error;

  num _total = 0;
  num _totalLalu = 0;
  int _jumlahPesanan = 0;
  List<double> _chartValues = List.filled(5, 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  String get _periodeKey => switch (_periode) {
        _Periode.minggu => 'minggu',
        _Periode.bulan => 'bulan',
        _Periode.tahun => 'tahun',
      };

  List<String> get _chartLabels => switch (_periode) {
        _Periode.minggu => const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
        _Periode.bulan => const ['Pekan 1', 'Pekan 2', 'Pekan 3', 'Pekan 4', 'Pekan 5'],
        _Periode.tahun => const [
            'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
            'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
          ],
      };

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Supabase.instance.client.rpc(
        'mitra_laporan_pendapatan',
        params: {'p_periode': _periodeKey},
      );
      final data = result as Map<String, dynamic>? ?? {};
      final chartRaw = (data['chart_values'] as List?) ?? [];
      final chartValues = chartRaw
          .map((v) => (v as num?)?.toDouble() ?? 0.0)
          .toList();
      if (mounted) {
        setState(() {
          _total = (data['total'] as num?) ?? 0;
          _totalLalu = (data['total_lalu'] as num?) ?? 0;
          _jumlahPesanan = ((data['jumlah_pesanan'] as num?)?.toInt()) ?? 0;
          _chartValues = chartValues.isEmpty
              ? List.filled(_chartLabels.length, 0.0)
              : chartValues;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loading = false;
        });
      }
    }
  }

  String _rupiah(num value) {
    final digits = value.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
      buf.write(digits[i]);
    }
    return 'Rp $buf';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: mitraTheme(Theme.of(context)),
      child: Scaffold(
        backgroundColor: MitraPalette.canvas,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildError()
                        : _buildContent(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const MitraBottomNavigator(currentIndex: 3),
      ),
    );
  }

  Widget _buildAppBar() => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: MitraPalette.line)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
              color: MitraPalette.ink,
            ),
            const SizedBox(width: 4),
            Text(
              'Laporan Pendapatan',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: MitraPalette.ink,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _load,
              tooltip: 'Muat ulang',
              color: MitraPalette.muted,
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: MitraPalette.muted),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat laporan.\n$_error',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(fontSize: 13, color: MitraPalette.muted),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );

  Widget _buildContent() {
    final change = _totalLalu == 0
        ? null
        : (_total - _totalLalu) / _totalLalu * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Pendapatan Mitra',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: MitraPalette.ink,
                ),
              ),
              Text(
                'Nilai tiket terbayar setelah diskon (biaya layanan dikecualikan)',
                style: GoogleFonts.manrope(fontSize: 12, color: MitraPalette.muted),
              ),
              const SizedBox(height: 16),

              // Period picker
              SegmentedButton<_Periode>(
                segments: const [
                  ButtonSegment(value: _Periode.minggu, label: Text('Minggu')),
                  ButtonSegment(value: _Periode.bulan, label: Text('Bulan')),
                  ButtonSegment(value: _Periode.tahun, label: Text('Tahun')),
                ],
                selected: {_periode},
                onSelectionChanged: (val) {
                  setState(() => _periode = val.first);
                  _load();
                },
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: MitraPalette.primary,
                  selectedForegroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Total card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: MitraPalette.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PENDAPATAN',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _rupiah(_total),
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_jumlahPesanan pesanan terbayar pada periode ini',
                      style: GoogleFonts.manrope(fontSize: 11, color: Colors.white60),
                    ),
                    if (change != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            change >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: const Color(0xFF9BF4D1),
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% vs periode lalu',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9BF4D1),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Lalu: ${_rupiah(_totalLalu)}',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MitraPalette.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren Pendapatan',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: MitraPalette.ink,
                      ),
                    ),
                    Text(
                      switch (_periode) {
                        _Periode.minggu => 'Per hari dalam minggu ini',
                        _Periode.bulan => 'Per pekan dalam bulan ini',
                        _Periode.tahun => 'Per bulan dalam tahun ini',
                      },
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: MitraPalette.muted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: _MitraIncomeChart(
                        labels: _chartLabels,
                        values: _chartValues,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Catatan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MitraPalette.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MitraPalette.primaryBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: MitraPalette.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Angka ini adalah porsi tiket Anda setelah diskon proporsional. '
                        'Biaya layanan Rp 20.000 per pesanan dicatat untuk LokaTrip. '
                        'Data diperbarui secara real-time dari database.',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          height: 1.5,
                          color: MitraPalette.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MitraIncomeChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  const _MitraIncomeChart({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) {
    final rawMax = values.fold(0.0, (a, b) => b > a ? b : a);
    final chartMax = rawMax == 0 ? 100.0 : rawMax * 1.3;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = groupIndex < labels.length ? labels[groupIndex] : '';
              final val = rod.toY;
              return BarTooltipItem(
                '$label\n',
                GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: val >= 1000000
                        ? 'Rp ${(val / 1000000).toStringAsFixed(1)} jt'
                        : val >= 1000
                            ? 'Rp ${(val / 1000).toStringAsFixed(0)} rb'
                            : 'Rp ${val.toInt()}',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF9BF4D1),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    labels[index],
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      color: MitraPalette.muted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: MitraPalette.line,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  color: MitraPalette.primary,
                  width: values.length <= 7 ? 22 : 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: chartMax,
                    color: MitraPalette.primaryLight,
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}
