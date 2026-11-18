import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/mitra_bottom_navigator.dart';

class LegalitasMitraScreen extends StatefulWidget {
  const LegalitasMitraScreen({super.key});

  @override
  State<LegalitasMitraScreen> createState() => _LegalitasMitraScreenState();
}

class _LegalitasMitraScreenState extends State<LegalitasMitraScreen> {
  int _selectedFilter = 0; // 0: Semua (4), 1: Perlu Tindakan (1), 2: Terverifikasi (3)
  String _lastAuditTime = 'Hari ini, 09:41 WIB';

  void _syncOss() {
    setState(() {
      final now = DateTime.now();
      final minute = now.minute.toString().padLeft(2, '0');
      final hour = now.hour.toString().padLeft(2, '0');
      _lastAuditTime = 'Hari ini, $hour:$minute WIB';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil menyinkronkan status legalitas dengan OSS RBA & Kemenparekraf.'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  Future<void> _uploadPolisBaru() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Polis Asuransi Baru',
            extensions: ['pdf', 'jpg', 'jpeg', 'png'],
          ),
        ],
      );
      if (file == null) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berkas ${file.name} berhasil diunggah. Menunggu verifikasi super admin.'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih berkas polis perpanjangan.')),
      );
    }
  }

  void _showFilePreview(String title, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Berkas: $fileName', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              'Status: Tervalidasi Resmi oleh Sistem LokaTrip & Instansi Terkait.',
              style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF059669)),
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

  void _showRiwayatVerifikasi() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat Audit & Verifikasi NIB',
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 14),
              _timelineTile('Verifikasi Otomatis OSS RBA', 'Selesai sinkronisasi KBLI 79120', '12 Agu 2026', true),
              _timelineTile('Validasi Tim Legal LokaTrip', 'Dokumen disetujui tanpa revisi', '14 Agu 2026', true),
              _timelineTile('Audit Berkala Tahunan', 'Terjadwal pada Q3 2027', 'Mendatang', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timelineTile(String title, String desc, String time, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: done ? const Color(0xFF059669) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700)),
                Text(desc, style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Text(time, style: GoogleFonts.manrope(fontSize: 10, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  void _showArmadaList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Daftar 14 Unit Armada Jeep 4x4',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 6,
            itemBuilder: (context, i) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.directions_car_filled_outlined, color: Color(0xFF1748D1)),
              title: Text('Toyota Hardtop 4x4 - N ${(8120 + i)} YX', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700)),
              subtitle: Text('KIR Aktif s/d 12 Mei 2027 • Layak Jalan', style: GoogleFonts.manrope(fontSize: 10, color: const Color(0xFF059669))),
            ),
          ),
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
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildComplianceGradeCard(),
                        const SizedBox(height: 18),
                        _buildFilterTabs(),
                        const SizedBox(height: 18),
                        _buildSectionTitle(),
                        const SizedBox(height: 14),

                        // Document Items based on filter
                        if (_selectedFilter == 0 || _selectedFilter == 2) ...[
                          _buildNibCard(),
                          const SizedBox(height: 14),
                          _buildTdupCard(),
                          const SizedBox(height: 14),
                        ],

                        if (_selectedFilter == 0 || _selectedFilter == 1) ...[
                          _buildInsuranceCard(),
                          const SizedBox(height: 14),
                        ],

                        if (_selectedFilter == 0 || _selectedFilter == 2) ...[
                          _buildArmadaCard(),
                          const SizedBox(height: 18),
                        ],

                        _buildLokaLegalCareDeskCard(),
                        const SizedBox(height: 18),
                        _buildFooterSyncStatus(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MitraBottomNavigator(currentIndex: 2),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pemberitahuan: 1 dokumen asuransi memerlukan perpanjangan.')),
                  );
                },
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
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF1748D1),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // Header Title
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified, size: 14, color: Color(0xFF1748D1)),
            const SizedBox(width: 6),
            Text(
              'KEMITRAAN RESMI LOKATRIP',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1748D1),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Pusat Legalitas & Kepatuhan',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pantau keabsahan izin usaha, polis asuransi, dan dokumen operasional agar wisata tetap tayang di LokaTrip.',
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // Compliance Grade & Progress Card
  Widget _buildComplianceGradeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 22,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATUS KEPATUHAN REGULASI',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '85%',
                            style: GoogleFonts.manrope(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF16A34A),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Patuh Aman',
                                  style: GoogleFonts.manrope(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Grade A',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1748D1),
                    ),
                  ),
                  Text(
                    'LokaVerif™',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Segmented Progress Bar (85%)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: 85,
                  child: Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1748D1), Color(0xFF10B981)],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: Container(
                    height: 6,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Bottom alert row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 15,
                  color: Color(0xFF1748D1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: const Color(0xFF334155),
                      ),
                      children: const [
                        TextSpan(text: '3 dari 4 dokumen utama berstatus Valid. '),
                        TextSpan(
                          text: '1 dokumen perlu perpanjangan',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(text: ' dalam 14 hari.'),
                      ],
                    ),
                  ),
                ),
              ],
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
          _filterPill(0, 'Semua Dokumen (4)'),
          const SizedBox(width: 8),
          _filterPill(1, 'Perlu Tindakan (1)'),
          const SizedBox(width: 8),
          _filterPill(2, 'Terverifikasi (3)'),
        ],
      ),
    );
  }

  Widget _filterPill(int index, String label) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1748D1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1748D1) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // Section Title: Dokumen Wajib & Perizinan
  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.gavel_rounded, size: 18, color: Color(0xFF1748D1)),
            const SizedBox(width: 8),
            Text(
              'Dokumen Wajib & Perizinan',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        Text(
          'OSS RBA &\nKemenparekraf',
          textAlign: TextAlign.right,
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // Document 1: Nomor Induk Berusaha (NIB)
  Widget _buildNibCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.domain_rounded, color: Color(0xFF1748D1), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Induk Berusaha (NIB)',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'KBLI 79120 • Aktivitas Biro Perjalanan Wisata',
                      style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, size: 20, color: Color(0xFF059669)),
            ],
          ),
          const SizedBox(height: 12),

          // Detail Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _tableRow('Nomor Dokumen', 'NIB-9120301923-2024'),
                const SizedBox(height: 6),
                _tableRow(
                  'Masa Berlaku',
                  'Seumur Hidup (OSS Berbasis Risiko)',
                  valueColor: const Color(0xFF059669),
                  bold: true,
                ),
                const SizedBox(height: 6),
                _tableRow('Instansi Penerbit', 'BKPM RI / OSS Nasional'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showFilePreview('NIB - Legalitas Usaha', 'NIB-9120301923-2024.pdf'),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined, size: 15, color: Color(0xFF1748D1)),
                    const SizedBox(width: 5),
                    Text(
                      'Lihat File PDF',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1748D1),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _showRiwayatVerifikasi,
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      'Riwayat Verifikasi',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
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

  // Document 2: Standar Usaha Pariwisata (TDUP)
  Widget _buildTdupCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.workspace_premium_outlined, color: Color(0xFF1748D1), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standar Usaha Pariwisata (TDUP)',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sertifikat Standar CHSE Clean & Safe',
                      style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, size: 20, color: Color(0xFF059669)),
            ],
          ),
          const SizedBox(height: 12),

          // Detail Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _tableRow('Nomor Registrasi', 'TDUP-JATIM-68410-2024'),
                const SizedBox(height: 6),
                _tableRow('Masa Berlaku', 's.d. 15 November 2027 (Aktif)', bold: true),
                const SizedBox(height: 6),
                _tableRow('Instansi Penerbit', 'Dinas Pariwisata Prov. Jawa Timur'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showFilePreview('TDUP Standar Usaha', 'TDUP-CHSE-JATIM-2024.pdf'),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined, size: 15, color: Color(0xFF1748D1)),
                    const SizedBox(width: 5),
                    Text(
                      'Lihat File',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1748D1),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEEF2FF),
                  foregroundColor: const Color(0xFF1748D1),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berkas TDUP masih berlaku aktif s/d 2027.')),
                  );
                },
                child: Text(
                  'Perbarui',
                  style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Document 3: Polis Asuransi Jiwa & Kecelakaan (Perlu Perpanjangan)
  Widget _buildInsuranceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: Color(0xFFDC2626), width: 3),
          left: BorderSide(color: Color(0xFFE2E8F0)),
          right: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined, color: Color(0xFFDC2626), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Polis Asuransi Jiwa & Kecelakaan',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PT Asuransi Jasa Indonesia (Jasindo)',
                      style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFDC2626)),
                    const SizedBox(width: 3),
                    Text(
                      'PERLU PERPANJANGAN',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Detail Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _tableRow('Nomor Polis', 'POL-JASINDO-TRIP-2025'),
                const SizedBox(height: 6),
                _tableRow(
                  'Masa Berlaku',
                  'Berakhir 30 Sep 2026 (Sisa 14 Hari)',
                  valueColor: const Color(0xFFDC2626),
                  bold: true,
                ),
                const SizedBox(height: 6),
                _tableRow('Cakupan Perlindungan', 'Santunan Medis & Jiwa Wisatawan'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Notice System
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notifications_active_outlined, size: 15, color: Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF334155), height: 1.35),
                      children: const [
                        TextSpan(
                          text: 'Pemberitahuan Sistem: ',
                          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                        ),
                        TextSpan(text: 'Super Admin akan '),
                        TextSpan(
                          text: 'menangguhkan otomatis',
                          style: TextStyle(fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
                        ),
                        TextSpan(
                          text: ' pemesanan tiket jika asuransi kedaluwarsa demi perlindungan hukum wisatawan.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Upload Button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F47D1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _uploadPolisBaru,
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: Text(
              'Unggah Polis Perpanjangan Baru (+)',
              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // Document 4: Sertifikat Uji Kelaikan Armada & K3
  Widget _buildArmadaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_filled_outlined, color: Color(0xFF1748D1), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sertifikat Uji Kelaikan Armada & K3',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Uji KIR 14 Unit Jeep Toyota Land Cruiser 4×4',
                      style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified, size: 20, color: Color(0xFF059669)),
            ],
          ),
          const SizedBox(height: 12),

          // Detail Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _tableRow('Dokumen Induk', 'KIR-DIS-2024-02623'),
                const SizedBox(height: 6),
                _tableRow('Masa Berlaku', 's.d. 12 Mei 2027', bold: true),
                const SizedBox(height: 6),
                _tableRow('Instansi Penerbit', 'Dishub Kab. Probolinggo'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: _showArmadaList,
                child: Row(
                  children: [
                    const Icon(Icons.folder_open_rounded, size: 15, color: Color(0xFF1748D1)),
                    const SizedBox(width: 5),
                    Text(
                      'Lihat Berkas (14 Unit)',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1748D1),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF059669)),
                  const SizedBox(width: 4),
                  Text(
                    'Armada Siap Jalan',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // LokaLegal Care Desk
  Widget _buildLokaLegalCareDeskCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0F47D1),
                child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LokaLegal Care Desk',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1748D1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Bantuan OSS',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ada kendala pengurusan izin OSS atau izin pemda? Tim Legal LokaTrip siap memberikan surat rekomendasi kemitraan resmi & pendampingan dinas.',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: const Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Button 1: Minta Surat Rekomendasi
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1748D1),
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mengunduh Surat Rekomendasi Kemitraan Resmi LokaTrip (PDF)...'),
                ),
              );
            },
            icon: const Icon(Icons.description_outlined, size: 16),
            label: Text(
              'Minta Surat Rekomendasi Mitra (PDF)',
              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),

          // Button 2: Hubungi Tim Legal via Chat
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F47D1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menghubungkan ke Tim Legal LokaTrip via Chat...'),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: Text(
              'Hubungi Tim Legal via Chat',
              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // Footer: Terakhir diaudit & Otomatis Sinkron OSS
  Widget _buildFooterSyncStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Terakhir diaudit: $_lastAuditTime',
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
        ),
        InkWell(
          onTap: _syncOss,
          child: Row(
            children: [
              const Icon(Icons.sync_rounded, size: 14, color: Color(0xFF1748D1)),
              const SizedBox(width: 4),
              Text(
                'Otomatis Sinkron OSS',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1748D1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableRow(String label, String value, {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
