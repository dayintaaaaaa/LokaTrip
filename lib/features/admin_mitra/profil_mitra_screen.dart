import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/session_manager.dart';
import '../../widgets/mitra_bottom_navigator.dart';
import '../login_screens.dart';
import 'ubah_data_mitra_screen.dart';

class ProfilMitraScreen extends StatefulWidget {
  const ProfilMitraScreen({super.key});

  @override
  State<ProfilMitraScreen> createState() => _ProfilMitraScreenState();
}

class _ProfilMitraScreenState extends State<ProfilMitraScreen> {
  bool _isBalanceVisible = true;

  void _copyPartnerId() {
    Clipboard.setData(const ClipboardData(text: 'MIT-00128'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID Kemitraan MIT-00128 berhasil disalin.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showTarikDanaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tarik Dana Manual',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo siap cair:',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Rp 46.200.000',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1748D1),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Rekening Tujuan: Bank Mandiri (1420019283741)\na.n CV PESONA NUSANTARA',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Proses pencairan diproses H-1 hari kerja SLA real-time.',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1748D1),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Permintaan penarikan dana manual Rp 46.200.000 sedang diproses ke Bank Mandiri.',
                  ),
                ),
              );
            },
            child: const Text('Konfirmasi Penarikan'),
          ),
        ],
      ),
    );
  }

  void _showRiwayatPayoutDialog() {
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
                      'Riwayat Payout & Komisi',
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
                _payoutItem(
                  date: '11 Sep 2026',
                  nominal: 'Rp 38.450.000',
                  bank: 'Bank Mandiri - Selesai',
                  statusColor: const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                _payoutItem(
                  date: '04 Sep 2026',
                  nominal: 'Rp 42.100.000',
                  bank: 'Bank Mandiri - Selesai',
                  statusColor: const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                _payoutItem(
                  date: '28 Agu 2026',
                  nominal: 'Rp 29.800.000',
                  bank: 'Bank Mandiri - Selesai',
                  statusColor: const Color(0xFF059669),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _payoutItem({
    required String date,
    required String nominal,
    required String bank,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nominal,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                bank,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Berhasil',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar dari Akun Mitra',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari Portal Mitra LokaTrip?',
          style: GoogleFonts.manrope(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SessionManager.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreens()),
        (route) => false,
      );
    }
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
                        _buildPartnerOverviewCard(),
                        const SizedBox(height: 20),
                        _buildFinancialWalletSection(),
                        const SizedBox(height: 20),
                        _buildCompanyPicSection(),
                        const SizedBox(height: 20),
                        _buildLogoutButton(),
                        const SizedBox(height: 20),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MitraBottomNavigator(currentIndex: 3),
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
                    const SnackBar(
                      content: Text(
                        'Semua sistem & payout operasional berjalan lancar.',
                      ),
                    ),
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

  // Page Header
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 13,
                color: Color(0xFF1748D1),
              ),
              const SizedBox(width: 5),
              Text(
                'PORTAL MITRA LOKATRIP',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1748D1),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Profil & Pengaturan Mitra',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kelola informasi badan usaha, rekening pencairan pendapatan tiket, dan keamanan akun mitra resmi.',
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // Partner Profile Overview Card
  Widget _buildPartnerOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar PN with checkmark
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF1445D1),
                    child: Text(
                      'PN',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CV Pesona Nusantara',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pengelola Wisata Bromo Adventure',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          'ID Kemitraan: ',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        InkWell(
                          onTap: _copyPartnerId,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'MIT-00128',
                                  style: GoogleFonts.sourceCodePro(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1748D1),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.copy_rounded,
                                  size: 11,
                                  color: Color(0xFF1748D1),
                                ),
                              ],
                            ),
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

          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1748D1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mitra Resmi Tier 1',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Rating Pelayanan 4.9 ★',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Status Akun Aktif Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Akun Aktif',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section 2: Ringkasan Finansial & Dompet
  Widget _buildFinancialWalletSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: Color(0xFF1748D1),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ringkasan Finansial & Dompet',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SLA Real-Time',
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Financial Card
        Container(
          padding: const EdgeInsets.all(16),
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
              // Ready Balance Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo Hasil Penjualan Tiket Siap Cair',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _isBalanceVisible = !_isBalanceVisible);
                    },
                    icon: Icon(
                      _isBalanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: const Color(0xFF94A3B8),
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _isBalanceVisible ? 'Rp 46.200.000' : 'Rp ••••••••••',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1748D1),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 10),

              // Scheduled payout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 15,
                    color: Color(0xFF1748D1),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          color: const Color(0xFF475569),
                        ),
                        children: [
                          const TextSpan(
                            text: 'Pencairan terjadwal berikutnya: ',
                          ),
                          TextSpan(
                            text: 'Kamis, 18 Sep 2026',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const TextSpan(text: ' (H-1 Payout LokaTrip)'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bank Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF1748D1),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank Mandiri - 1420019283741',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Terverifikasi ✓',
                                  style: GoogleFonts.manrope(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'a.n CV PESONA NUSANTARA',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Button 1: Solid Blue Tarik Dana Manual
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1748D1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showTarikDanaDialog,
                icon: const Icon(Icons.payments_outlined, size: 17),
                label: Text(
                  'Tarik Dana Manual',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Button 2: Light Blue Riwayat Payout & Komisi
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF6FF),
                  foregroundColor: const Color(0xFF1748D1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                  ),
                ),
                onPressed: _showRiwayatPayoutDialog,
                icon: const Icon(Icons.receipt_long_outlined, size: 17),
                label: Text(
                  'Riwayat Payout & Komisi',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Section 3: Informasi Badan Usaha & PIC
  Widget _buildCompanyPicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.business_rounded,
                  size: 18,
                  color: Color(0xFF1748D1),
                ),
                const SizedBox(width: 8),
                Text(
                  'Informasi Badan Usaha & PIC',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 11,
                    color: Color(0xFF1748D1),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tervalidasi NIB',
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1748D1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Company Details Card
        Container(
          padding: const EdgeInsets.all(16),
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
              // PIC Penanggung Jawab
              _companyInfoRow(
                icon: Icons.badge_outlined,
                label: 'PIC Penanggung Jawab',
                value: 'Hendra Wijaya',
                extra: Text(
                  'Direktur Operasional',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1748D1),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Email Resmi Perusahaan
              _companyInfoRow(
                icon: Icons.email_outlined,
                label: 'Email Resmi Perusahaan',
                value: 'hendra@pesonanusantara.id',
              ),
              const SizedBox(height: 14),

              // Nomor WhatsApp Operasional
              _companyInfoRow(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Nomor WhatsApp Operasional',
                value: '+62 811-2345-6789',
                extra: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Terhubung',
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Alamat Kantor / Basecamp
              _companyInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Alamat Kantor / Basecamp Wisata',
                value:
                    'Jl. Raya Bromo No. 45, Sukapura, Kab. Probolinggo, Jawa Timur',
              ),
              const SizedBox(height: 16),

              // Edit Button
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: const Color(0xFF1748D1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UbahDataMitraScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(
                  'Ubah Data Perusahaan & PIC',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _companyInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? extra,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF1748D1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  if (extra != null) ...[const SizedBox(width: 8), extra],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Logout Button
  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFDC2626),
        backgroundColor: const Color(0xFFFEF2F2),
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: Color(0xFFFEE2E2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _logout,
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: Text(
        'Keluar dari Akun Mitra',
        style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  // Footer
  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 13,
              color: Color(0xFF1748D1),
            ),
            const SizedBox(width: 5),
            Text(
              'LokaTrip Mitra Versi 2.4.0 (Enterprise Partner Build)',
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Hak Cipta © 2026 PT LokaTrip Nusantara Terpadu. All rights reserved.',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 9,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
