import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/mitra_bottom_navigator.dart';
import 'pengajuan_mitra_screens.dart';
import 'profil_mitra_screen.dart';

class WisataSayaMitraScreen extends StatefulWidget {
  const WisataSayaMitraScreen({super.key});

  @override
  State<WisataSayaMitraScreen> createState() => _WisataSayaMitraScreenState();
}

class _WisataSayaMitraScreenState extends State<WisataSayaMitraScreen> {
  int _selectedFilter = 0; // 0: Semua, 1: Aktif, 2: Ditinjau, 3: Perlu Revisi
  bool _isBromoOpen = true;

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
                        color: const Color(0xFF0F172A),
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
                  color: const Color(0xFF1748D1),
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
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
                color: const Color(0xFF1748D1),
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
              backgroundColor: const Color(0xFF1748D1),
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
                color: const Color(0xFF1748D1),
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
                ? const Color(0xFF1748D1)
                : (done ? const Color(0xFF059669) : const Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight:
                    inProgress || done ? FontWeight.w600 : FontWeight.w400,
                color: inProgress
                    ? const Color(0xFF1748D1)
                    : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
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
                        if (_selectedFilter == 0 || _selectedFilter == 1) ...[
                          _buildCard1Bromo(),
                          const SizedBox(height: 16),
                        ],

                        if (_selectedFilter == 0 || _selectedFilter == 3) ...[
                          _buildCard2Rafting(),
                          const SizedBox(height: 16),
                        ],

                        if (_selectedFilter == 0 || _selectedFilter == 2) ...[
                          _buildCard3KawahIjen(),
                          const SizedBox(height: 16),
                        ],

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
    );
  }

  // Top App Bar
  Widget _buildTopAppBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 24),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF1748D1),
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
                  color: Color(0xFF0F172A),
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
              backgroundColor: Color(0xFF1748D1),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1748D1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'KATALOG DESTINASI MITRA',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1748D1),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                'ID: MTR-9821',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Wisata Saya',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kelola destinasi, paket tiket, kuota dan status tayang di aplikasi LokaTrip.',
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: const Color(0xFF64748B),
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
          colors: [Color(0xFF0F47D1), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1748D1).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EKSPANSI BISNIS',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
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
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F47D1),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
        ],
      ),
    );
  }

  // 3 Summary Stats in Row
  Widget _buildSummaryStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _statItem(
            icon: Icons.public_rounded,
            badgeColor: const Color(0xFF059669),
            value: '1',
            label: 'Wisata Aktif',
            tag: 'Tayang',
            tagColor: const Color(0xFF059669),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statItem(
            icon: Icons.hourglass_top_rounded,
            badgeColor: const Color(0xFF2563EB),
            value: '2',
            label: 'Dalam Kurasi',
            tag: 'Audit Tim',
            tagColor: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statItem(
            icon: Icons.confirmation_number_outlined,
            topBadge: '+14%',
            topBadgeColor: const Color(0xFF059669),
            value: '1.482',
            label: 'Tiket Bulan Ini',
            tag: 'Terverifikasi',
            tagColor: const Color(0xFF64748B),
          ),
        ),
      ],
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Icon(icon, size: 15, color: const Color(0xFF1748D1)),
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
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: const Color(0xFF64748B),
            ),
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
            label: 'Semua 3',
            isSelected: _selectedFilter == 0,
          ),
          const SizedBox(width: 8),
          _filterPill(
            index: 1,
            label: 'Aktif Tayang 1',
            dotColor: const Color(0xFF059669),
            isSelected: _selectedFilter == 1,
          ),
          const SizedBox(width: 8),
          _filterPill(
            index: 2,
            label: 'Ditinjau 1',
            dotColor: const Color(0xFF2563EB),
            isSelected: _selectedFilter == 2,
          ),
          const SizedBox(width: 8),
          _filterPill(
            index: 3,
            label: 'Perlu Revisi 1',
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
          color: isSelected ? const Color(0xFF1748D1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1748D1)
                : const Color(0xFFE2E8F0),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          color: const Color(0xFF0F172A),
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
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                color: Color(0xFF1748D1),
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
                                  color: const Color(0xFF0F172A),
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
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1748D1),
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
                          color: const Color(0xFFEFF6FF),
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
                                color: Color(0xFF1748D1),
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
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    '1.482 Tiket',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
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
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    'Rp 370,5 Jt',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
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
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                _isBromoOpen
                                    ? 'Buka untuk Reservasi'
                                    : 'Tutup Sementara',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
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
                          backgroundColor: const Color(0xFF0F47D1),
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
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
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
                        color: Color(0xFF1748D1),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          color: Color(0xFF64748B),
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
                            color: const Color(0xFF64748B),
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
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Probolinggo • Wisata Ekstrem',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'AUDIT SUPER ADMIN',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1748D1),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 11,
                              color: Color(0xFF1748D1),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Sisa 18 Jam',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1748D1),
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
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Banyuwangi • Wisata Gunung',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
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
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          'Tahap 2 / 4',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
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
                        backgroundColor: Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1748D1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diajukan 2 hari yang lalu',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
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
                        color: const Color(0xFF1748D1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: Color(0xFF1748D1),
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
                    color: const Color(0xFF0F172A),
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
                          color: const Color(0xFF1748D1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.north_east_rounded,
                        size: 13,
                        color: Color(0xFF1748D1),
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

