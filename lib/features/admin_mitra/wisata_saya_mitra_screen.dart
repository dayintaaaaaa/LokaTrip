import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/mitra_theme.dart';

import '../../core/api_client.dart';
import '../../core/session_manager.dart';
import '../../widgets/mitra_bottom_navigator.dart';
import '../../widgets/gambar_wisata.dart';
import 'pengajuan_mitra_screens.dart';
import 'profil_mitra_screen.dart';
import 'edit_wisata_mitra_screen.dart';

class WisataSayaMitraScreen extends StatefulWidget {
  const WisataSayaMitraScreen({super.key});

  @override
  State<WisataSayaMitraScreen> createState() => _WisataSayaMitraScreenState();
}

class _WisataSayaMitraScreenState extends State<WisataSayaMitraScreen> {
  int _selectedFilter = 0; // 0: Semua, 1: Aktif, 2: Ditinjau, 3: Perlu Revisi
  bool _isBromoOpen = true;
  List<Map<String, dynamic>> _wisata = const [];
  bool _loadingWisata = true;
  String? _wisataError;

  @override
  void initState() {
    super.initState();
    _loadWisata();
  }

  Future<void> _loadWisata() async {
    try {
      final token = await SessionManager.currentMitraToken();
      if (token == null) {
        throw const ApiException(
          'Sesi mitra tidak tersedia. Silakan login kembali.',
        );
      }
      final rows = await MitraApi.wisata(token);
      if (mounted) setState(() => _wisata = rows);
    } catch (error) {
      _wisataError = error.toString();
    } finally {
      if (mounted) setState(() => _loadingWisata = false);
    }
  }

  List<Map<String, dynamic>> get _wisataTampil => _wisata.where((row) {
    final status = row['status_approve'];
    return _selectedFilter == 0 ||
        (_selectedFilter == 1 && status == 'Y') ||
        (_selectedFilter == 2 && status == 'N') ||
        (_selectedFilter == 3 && status != 'Y' && status != 'N');
  }).toList();

  Widget _liveWisataCard(Map<String, dynamic> row) {
    final photos = row['foto_wisata'] is List
        ? (row['foto_wisata'] as List)
              .whereType<Map<String, dynamic>>()
              .toList()
        : <Map<String, dynamic>>[];
    photos.sort(
      (a, b) =>
          ((a['urutan'] ?? 0) as num).compareTo((b['urutan'] ?? 0) as num),
    );
    final packages = row['paket_wisata'] is List
        ? row['paket_wisata'] as List
        : const [];
    final prices = <int>[];
    for (final package in packages.whereType<Map<String, dynamic>>()) {
      final details = package['detail_paket'];
      if (details is List) {
        for (final detail in details.whereType<Map<String, dynamic>>()) {
          final price = detail['harga'];
          if (price is num && price > 0) prices.add(price.toInt());
        }
      }
    }
    final status = row['status_approve'] as String? ?? 'N';
    final statusText = status == 'Y'
        ? 'Aktif tayang'
        : status == 'N'
        ? 'Dalam kurasi'
        : 'Perlu revisi';
    final statusColor = status == 'Y'
        ? MitraPalette.success
        : status == 'N'
        ? MitraPalette.warning
        : MitraPalette.danger;
    final category = row['kategori'];
    final categoryName = category is Map<String, dynamic>
        ? category['nama_kategori'] as String?
        : null;

    return Material(
      color: MitraPalette.surface,
      borderRadius: BorderRadius.circular(MitraMetrics.cardRadius),
      child: InkWell(
        onTap: () => _editWisata(row),
        borderRadius: BorderRadius.circular(MitraMetrics.cardRadius),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MitraMetrics.cardRadius),
            border: Border.all(color: MitraPalette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: photos.isEmpty
                          ? Container(
                              color: MitraPalette.primaryLight,
                              child: const Icon(
                                Icons.landscape_rounded,
                                color: MitraPalette.primary,
                              ),
                            )
                          : GambarWisata(
                              path: photos.first['url_foto'] as String?,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      row['nama_wisata'] as String? ?? 'Wisata',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        height: 1.25,
                        color: MitraPalette.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.manrope(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${row['kota'] ?? row['lokasi'] ?? 'Lokasi belum diisi'} / ${categoryName ?? 'Wisata'}',
                style: GoogleFonts.manrope(
                  color: MitraPalette.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${packages.length} paket / ${prices.isEmpty ? 'Harga belum diisi' : 'Mulai Rp ${prices.reduce((a, b) => a < b ? a : b)}'}',
                      style: GoogleFonts.manrope(
                        color: MitraPalette.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Kelola',
                    style: GoogleFonts.manrope(
                      color: MitraPalette.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: MitraPalette.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editWisata(Map<String, dynamic> row) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => EditWisataMitraScreen(wisata: row),
      ),
    );
    if (updated == true) await _loadWisata();
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pemberitahuan Mitra',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: MitraPalette.ink,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _notificationTile(
                  title: 'Verifikasi Berkas Kawah Ijen',
                  subtitle:
                      'Tim kurator sedang menguji SOP pemandu dan sertifikat P3K.',
                  time: '18 jam tersisa',
                  color: MitraPalette.primary,
                  icon: Icons.hourglass_top_rounded,
                ),
                const SizedBox(height: 8),
                _notificationTile(
                  title: 'Perhatian: Polis Asuransi Kedaluwarsa',
                  subtitle:
                      'Mohon perbarui dokumen asuransi Paket Rafting Pekalen.',
                  time: 'Kemarin',
                  color: const Color(0xFFDC2626),
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _notificationTile({
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: MitraPalette.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: MitraPalette.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManageQuotaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Kelola Kuota & Tiket Bromo',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kuota Harian Saat Ini: 120 Jeep',
              style: GoogleFonts.manrope(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Terisi Hari Ini: 82 Jeep (68%)',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MitraPalette.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Harga Tiket: Rp 350.000 / pax',
              style: GoogleFonts.manrope(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: MitraPalette.primary,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan tiket & kuota berhasil disimpan.'),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showRepairDocsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Perbarui Dokumen Polis Asuransi',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Polis sertifikat asuransi keselamatan wisatawan telah kedaluwarsa. Mohon unggah berkas pembaharuan.',
              style: GoogleFonts.manrope(fontSize: 12),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Berkas polis baru berhasil diunggah.'),
                  ),
                );
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Pilih Berkas PDF Baru'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showAuditDetailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Detail Audit Kawah Ijen',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _auditStep('1. Pengecekan Berkas Legalitas', true),
            _auditStep('2. Verifikasi SOP & Pemandu', true, inProgress: true),
            _auditStep('3. Peninjauan Fasilitas Lapangan', false),
            _auditStep('4. Persetujuan Final & Publikasi', false),
            const SizedBox(height: 12),
            Text(
              'SLA Sisa Waktu: 18 Jam tersisa',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: MitraPalette.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _auditStep(String title, bool done, {bool inProgress = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            inProgress
                ? Icons.timelapse_rounded
                : (done ? Icons.check_circle : Icons.radio_button_unchecked),
            size: 18,
            color: inProgress
                ? MitraPalette.primary
                : (done ? const Color(0xFF059669) : const Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: inProgress || done
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: inProgress ? MitraPalette.primary : MitraPalette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = MitraPalette.canvas;

    return Theme(
      data: mitraTheme(Theme.of(context)),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(),
                          const SizedBox(height: 16),
                          _buildExpansionBanner(),
                          const SizedBox(height: 16),
                          _buildSummaryStatsRow(),
                          const SizedBox(height: 18),
                          _buildFilterTabs(),
                          const SizedBox(height: 16),

                          // Destination Cards according to selected filter
                          if (_loadingWisata)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(28),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_wisataError != null)
                            _buildLoadError()
                          else if (_wisataTampil.isEmpty)
                            _buildEmptyState()
                          else
                            ..._wisataTampil.map(_liveWisataCard),

                          _buildHelpSupportCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const MitraBottomNavigator(currentIndex: 1),
      ),
    );
  }

  Widget _buildLoadError() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: MitraPalette.surface,
      borderRadius: BorderRadius.circular(MitraMetrics.cardRadius),
      border: Border.all(color: MitraPalette.line),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_outlined, color: MitraPalette.danger),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _wisataError ?? 'Data wisata belum dapat dimuat.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 1.4,
              color: MitraPalette.muted,
            ),
          ),
        ),
        IconButton(
          onPressed: _loadWisata,
          tooltip: 'Coba lagi',
          icon: const Icon(Icons.refresh_rounded, color: MitraPalette.primary),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() {
    final hasNoDestinations = _wisata.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: MitraPalette.surface,
        borderRadius: BorderRadius.circular(MitraMetrics.cardRadius),
        border: Border.all(color: MitraPalette.line),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: MitraPalette.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.landscape_outlined,
              color: MitraPalette.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasNoDestinations ? 'Belum ada destinasi' : 'Belum ada hasil',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: MitraPalette.ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            hasNoDestinations
                ? 'Mulai daftarkan tempat wisata agar dapat dikelola di sini.'
                : 'Belum ada wisata dengan status yang dipilih.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 1.45,
              color: MitraPalette.muted,
            ),
          ),
        ],
      ),
    );
  }

  // Top App Bar
  Widget _buildTopAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: MitraPalette.line)),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 24),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: MitraPalette.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'MITRA',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          // Notification Bell
          Stack(
            children: [
              IconButton(
                onPressed: _showNotificationSheet,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: MitraPalette.ink,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Profile Avatar
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const ProfilMitraScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: MitraPalette.primary,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // Header Title & Subtitle
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AREA MITRA  /  DESTINASI',
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: MitraPalette.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Wisata Saya',
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -.7,
            color: MitraPalette.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Kelola destinasi, paket tiket, kuota dan status tayang di aplikasi LokaTrip.',
          style: GoogleFonts.manrope(
            fontSize: 13,
            height: 1.5,
            color: MitraPalette.muted,
          ),
        ),
      ],
    );
  }

  // Ekspansi Bisnis Banner
  Widget _buildExpansionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MitraPalette.primaryDark, MitraPalette.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MitraPalette.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.add_location_alt_outlined,
                    color: MitraPalette.accent,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AREA PERTUMBUHAN',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tambah Objek Wisata',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Jangkau jutaan wisatawan domestik & mancanegara.',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MitraPalette.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    MitraMetrics.controlRadius,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const PengajuanMitraScreens(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: Text(
                'Daftarkan',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3 Summary Stats in Row
  Widget _buildSummaryStatsRow() {
    final activeCount = _wisata
        .where((item) => item['status_approve'] == 'Y')
        .length;
    final pendingCount = _wisata
        .where((item) => item['status_approve'] == 'N')
        .length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 430 ? 2 : 3;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: width,
              child: _statItem(
                icon: Icons.explore_outlined,
                badgeColor: MitraPalette.primary,
                value: '${_wisata.length}',
                label: 'Total destinasi',
                tag: 'Terdaftar',
                tagColor: MitraPalette.muted,
              ),
            ),
            SizedBox(
              width: width,
              child: _statItem(
                icon: Icons.public_rounded,
                badgeColor: MitraPalette.success,
                value: '$activeCount',
                label: 'Wisata aktif',
                tag: 'Tayang',
                tagColor: MitraPalette.success,
              ),
            ),
            SizedBox(
              width: width,
              child: _statItem(
                icon: Icons.hourglass_top_rounded,
                badgeColor: MitraPalette.warning,
                value: '$pendingCount',
                label: 'Dalam kurasi',
                tag: 'Ditinjau tim',
                tagColor: MitraPalette.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statItem({
    required IconData icon,
    Color? badgeColor,
    String? topBadge,
    Color? topBadgeColor,
    required String value,
    required String label,
    required String tag,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MitraPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: MitraPalette.primaryLight,
                child: Icon(icon, size: 15, color: MitraPalette.primary),
              ),
              if (topBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: topBadgeColor?.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    topBadge,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: topBadgeColor,
                    ),
                  ),
                )
              else if (badgeColor != null)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: MitraPalette.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 10, color: MitraPalette.muted),
          ),
          const SizedBox(height: 2),
          Text(
            tag,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: tagColor,
            ),
          ),
        ],
      ),
    );
  }

  // Filter Tabs
  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterPill(
            index: 0,
            label: 'Semua ${_wisata.length}',
            isSelected: _selectedFilter == 0,
          ),
          const SizedBox(width: 8),
          _filterPill(
            index: 1,
            label:
                'Aktif Tayang ${_wisata.where((item) => item['status_approve'] == 'Y').length}',
            dotColor: const Color(0xFF059669),
            isSelected: _selectedFilter == 1,
          ),
          const SizedBox(width: 8),
          _filterPill(
            index: 2,
            label:
                'Ditinjau ${_wisata.where((item) => item['status_approve'] == 'N').length}',
            dotColor: MitraPalette.warning,
            isSelected: _selectedFilter == 2,
          ),
          const SizedBox(width: 8),
          _filterPill(
            index: 3,
            label:
                'Perlu Revisi ${_wisata.where((item) => item['status_approve'] != 'Y' && item['status_approve'] != 'N').length}',
            dotColor: const Color(0xFFDC2626),
            isSelected: _selectedFilter == 3,
          ),
        ],
      ),
    );
  }

  Widget _filterPill({
    required int index,
    required String label,
    Color? dotColor,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? MitraPalette.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? MitraPalette.primary : MitraPalette.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null && !isSelected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card 1: Bromo Sunrise Jeep Tour (Aktif Tayang)
  Widget _buildCard1Bromo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MitraPalette.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Image with Badges & Text Overlay
          Stack(
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?w=800&auto=format&fit=crop&q=80',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF334155), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.landscape_rounded,
                      size: 48,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
              // Gradient Shade
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Badges on Top
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AKTIF TAYANG',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: MitraPalette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFBBF24),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.9 (342)',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Title on Bottom of Image
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WISATA ALAM & PETUALANGAN',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Gunung Bromo Sunrise Jeep Tour',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Kab. Probolinggo, Jawa Timur',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quota Progress Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MitraPalette.canvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MitraPalette.line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car_filled_outlined,
                                size: 16,
                                color: MitraPalette.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kuota Hari Ini',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '82 / 120 Terisi ',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: MitraPalette.ink,
                                ),
                              ),
                              Text(
                                '(68%)',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 0.68,
                          minHeight: 6,
                          backgroundColor: MitraPalette.line,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            MitraPalette.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2 Stat Boxes Side-by-Side
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MitraPalette.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 16,
                                color: MitraPalette.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penjualan Tiket',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: MitraPalette.muted,
                                    ),
                                  ),
                                  Text(
                                    '1.482 Tiket',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: MitraPalette.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.payments_outlined,
                                size: 16,
                                color: Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pendapatan Kotor',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      color: MitraPalette.muted,
                                    ),
                                  ),
                                  Text(
                                    'Rp 370,5 Jt',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: MitraPalette.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Operational Status Switch
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: MitraPalette.canvas,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MitraPalette.line),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isBromoOpen
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Operasional',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: MitraPalette.ink,
                                ),
                              ),
                              Text(
                                _isBromoOpen
                                    ? 'Buka untuk Reservasi'
                                    : 'Tutup Sementara',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: MitraPalette.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isBromoOpen,
                        activeThumbColor: Colors.white,
                        activeTrackColor: const Color(0xFF059669),
                        onChanged: (val) {
                          setState(() => _isBromoOpen = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                val
                                    ? 'Status operasional diaktifkan.'
                                    : 'Status operasional dinonaktifkan sementara.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: MitraPalette.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _showManageQuotaDialog,
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        label: Text(
                          'Kelola Tiket & Kuota',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      style: IconButton.styleFrom(
                        side: const BorderSide(
                          color: MitraPalette.primaryBorder,
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Membuka pratinjau halaman wisata di aplikasi pengunjung.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: MitraPalette.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 2: Paket Rafting Sungai Pekalen (Perlu Revisi)
  Widget _buildCard2Rafting() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MitraPalette.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1530866495561-507c9faab2ed?w=600&auto=format&fit=crop&q=80',
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 84,
                        height: 84,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.water_damage_rounded,
                          color: MitraPalette.muted,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PERLU REVISI',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                        Text(
                          'SLA: 24 Jam',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: MitraPalette.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Paket Rafting Sungai Pekalen',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: MitraPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: MitraPalette.muted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Probolinggo â€¢ Wisata Ekstrem',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: MitraPalette.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.do_not_disturb_on_rounded,
                          size: 13,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reservasi Ditangguhkan',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Admin Review Notice Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 15,
                      color: Color(0xFFB91C1C),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Catatan Kurasi Super Admin:',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Polis sertifikat asuransi keselamatan wisatawan telah kedaluwarsa. Mohon unggah pembaharuan polis tahun berjalan.',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Repair Button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _showRepairDocsDialog,
            icon: const Icon(Icons.description_outlined, size: 16),
            label: Text(
              'Perbaiki Dokumen & Unggah Ulang',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: Kawah Ijen Blue Fire Experience (Audit Super Admin)
  Widget _buildCard3KawahIjen() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MitraPalette.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with Verified Shield
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?w=600&auto=format&fit=crop&q=80',
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 84,
                        height: 84,
                        color: const Color(0xFF1E293B),
                        child: const Icon(
                          Icons.nightlife_rounded,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: const Icon(
                      Icons.verified_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: MitraPalette.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AUDIT SUPER ADMIN',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: MitraPalette.primary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 11,
                              color: MitraPalette.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Sisa 18 Jam',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: MitraPalette.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kawah Ijen Blue Fire Experience',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: MitraPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: MitraPalette.muted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Banyuwangi â€¢ Wisata Gunung',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: MitraPalette.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Verifikasi SOP & Pemandu',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: MitraPalette.muted,
                          ),
                        ),
                        Text(
                          'Tahap 2 / 4',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: MitraPalette.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 4,
                        backgroundColor: MitraPalette.line,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          MitraPalette.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: MitraPalette.line),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diajukan 2 hari yang lalu',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: MitraPalette.muted,
                ),
              ),
              InkWell(
                onTap: _showAuditDetailDialog,
                child: Row(
                  children: [
                    Text(
                      'Lacak Detail Audit',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: MitraPalette.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: MitraPalette.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Help & Support Card
  Widget _buildHelpSupportCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF6EE7B7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 22,
              color: Color(0xFF065F46),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh Bantuan Optimasi Listing?',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: MitraPalette.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Konsultasikan gratis bersama Tim Kurasi LokaTrip via WhatsApp Resmi Mitra.',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Menghubungi Tim Kurator via WhatsApp Resmi LokaTrip (+62 811-2345-6789)...',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'HUBUNGI TIM KURATOR',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: MitraPalette.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.north_east_rounded,
                        size: 13,
                        color: MitraPalette.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
