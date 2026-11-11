import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/mitra_bottom_navigator.dart';

class LegalitasMitraScreen extends StatelessWidget {
  const LegalitasMitraScreen({super.key});

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
                        _buildStatusOverviewCard(),
                        const SizedBox(height: 16),
                        _buildDocumentsList(context),
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
          IconButton(
            onPressed: () {},
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              'KEPATUHAN & HUKUM BISNIS',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1748D1),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Legalitas Usaha',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pastikan semua perizinan dan asuransi operasional Anda tetap aktif dan sah.',
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOverviewCard() {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEFF6FF),
            child: const Icon(
              Icons.verified_user_rounded,
              size: 24,
              color: Color(0xFF1748D1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Kepatuhan: 85% Memenuhi',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '1 dokumen memerlukan pembaruan (Polis Asuransi Rafting).',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(BuildContext context) {
    return Column(
      children: [
        _docItem(
          title: 'Nomor Induk Berusaha (NIB)',
          number: '9120003481928',
          status: 'Valid (Terverifikasi OSS)',
          color: const Color(0xFF059669),
          isDone: true,
        ),
        const SizedBox(height: 10),
        _docItem(
          title: 'Tanda Daftar Usaha Pariwisata (TDUP)',
          number: 'TDUP-503/128/PAR/2024',
          status: 'Berlaku s/d 14 Okt 2027',
          color: const Color(0xFF059669),
          isDone: true,
        ),
        const SizedBox(height: 10),
        _docItem(
          title: 'Polis Asuransi Wisatawan (Sungai Pekalen)',
          number: 'POL-JASARAHARJA-88912',
          status: 'Kedaluwarsa (Perlu Pembaharuan)',
          color: const Color(0xFFDC2626),
          isDone: false,
        ),
        const SizedBox(height: 10),
        _docItem(
          title: 'Sertifikasi SOP & Pemandu (Kawah Ijen)',
          number: 'HPI-BNI-2025/VII',
          status: 'Tahap Verifikasi Kurator',
          color: const Color(0xFF1748D1),
          isDone: false,
        ),
      ],
    );
  }

  Widget _docItem({
    required String title,
    required String number,
    required String status,
    required Color color,
    required bool isDone,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
              isDone ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
              size: 18,
              color: color,
            ),
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
                const SizedBox(height: 2),
                Text(
                  'No. Dokumen: $number',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
}

