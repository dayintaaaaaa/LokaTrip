import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/admin_auth_service.dart';
import '../../core/session_manager.dart';
import '../../widgets/admin_bottom_navigator.dart';
import '../../widgets/admin_notification_button.dart';
import 'mitra_admin_screens.dart';
import 'laporan_admin_screens.dart';
import 'notifikasi_admin_screens.dart';
import 'perizinan_admin_screens.dart';
import 'profil_screens.dart';
import '../login_screens.dart';
import 'verifikasi_mitra_admin_screens.dart';

const _navy = Color(0xFF10243A);
const _blue = Color(0xFF063CBF);
const _muted = Color(0xFF50566A);
const _page = Color(0xFFF7F8FD);
const _border = Color(0xFFE9ECF3);

typedef DashboardLoader = Future<Map<String, dynamic>> Function();
typedef WisataLoader = Future<List<Map<String, dynamic>>> Function();
typedef DashboardDocumentsLoader =
    Future<List<Map<String, dynamic>>> Function();

class DashboardAdminScreens extends StatefulWidget {
  final DashboardLoader? dashboardLoader;
  final WisataLoader? wisataLoader;
  final DashboardDocumentsLoader? documentsLoader;

  const DashboardAdminScreens({
    super.key,
    this.dashboardLoader,
    this.wisataLoader,
    this.documentsLoader,
  });

  @override
  State<DashboardAdminScreens> createState() => _DashboardAdminScreensState();
}

class _DashboardAdminScreensState extends State<DashboardAdminScreens> {
  int _summaryRevision = 0;

  void _openProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfilAdminScreens()),
    );
  }

  void _openMitra(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MitraAdminScreens()),
    );
  }

  void _openReport(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LaporanAdminScreens()),
    );
  }

  void _openLicenses(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PerizinanAdminScreens()),
    );
  }

  Future<void> _openPermitList(
    BuildContext context, {
    String initialFilter = 'Semua',
    String? initialPermitId,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PerizinanAdminScreens(
          initialFilter: initialFilter,
          initialPermitId: initialPermitId,
          documentsLoader: widget.documentsLoader,
        ),
      ),
    );
    if (mounted) setState(() => _summaryRevision++);
  }

  void _openVerification(
    BuildContext context, {
    required String id,
    required String partner,
    required String destination,
    required String category,
    required String dates,
    required String note,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => VerifikasiMitraAdminScreens(
          id: id,
          partner: partner,
          destination: destination,
          category: category,
          dates: dates,
          auditor: 'Admin LokaTrip',
          note: note,
          status: StatusAuditMitra.menunggu,
          rejectedStep: 0,
          onApproved: (_) => _saveWisataDecision(id, 'approve'),
          onRejected: (_) => _saveWisataDecision(id, 'reject'),
          onRevision: () => _saveWisataDecision(id, 'pending'),
        ),
      ),
    );
  }

  Future<void> _saveWisataDecision(String id, String decision) async {
    final token = SessionManager.adminAccessToken;
    final idValue = int.tryParse(id);
    if (token == null || idValue == null) {
      throw const AdminAuthException('Sesi admin atau ID wisata tidak valid.');
    }
    await AdminAuthService.decideWisata(
      accessToken: token,
      id: idValue,
      decision: decision,
    );
    if (mounted) setState(() => _summaryRevision++);
  }

  Widget _pendingWisataList() {
    final token = SessionManager.adminAccessToken;

    if (widget.wisataLoader == null && token == null) {
      return const Text('Sesi admin tidak tersedia.');
    }

    final future =
        widget.wisataLoader?.call() ??
        AdminAuthService.getWisata(accessToken: token!, status: 'N');

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text('Daftar wisata belum dapat dimuat: ${snapshot.error}');
        }

        final rows = snapshot.data ?? const [];

        if (rows.isEmpty) {
          return const Text('Tidak ada wisata yang menunggu verifikasi.');
        }

        return Column(
          children: rows.take(5).map((row) {
            final ownerValue = row['admin_wisata'];

            final owner = ownerValue is Map<String, dynamic>
                ? ownerValue
                : <String, dynamic>{};

            final categoryValue = row['kategori'];

            final category = categoryValue is Map<String, dynamic>
                ? categoryValue['nama_kategori'] as String?
                : null;

            final id = (row['id_wisata'] as num?)?.toInt() ?? 0;

            final title = row['nama_wisata'] as String? ?? 'Wisata';

            final partner =
                owner['nama_lengkap_admin'] as String? ??
                owner['username'] as String? ??
                'Mitra';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _VerificationCard(
                partner: partner.toUpperCase(),
                title: title,
                date: 'Menunggu verifikasi',
                category: category ?? 'Wisata',
                documents: 'ID wisata $id',
                icon: Icons.landscape_rounded,
                imageColor: const Color(0xFFB8D7C8),
                onPressed: () => _openVerification(
                  context,
                  id: '$id',
                  partner: partner,
                  destination: title,
                  category: category ?? 'Wisata',
                  dates: 'Menunggu verifikasi admin',
                  note:
                      row['deskripsi'] as String? ??
                      'Periksa informasi wisata mitra.',
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _expiringDocumentsList() {
    final token = SessionManager.adminAccessToken;

    if (widget.documentsLoader == null && token == null) {
      return const Text('Sesi admin tidak tersedia.');
    }

    final future =
        widget.documentsLoader?.call() ??
        AdminAuthService.getDocuments(accessToken: token!);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Data masa berlaku dokumen belum dapat dimuat: ${snapshot.error}',
          );
        }

        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);

        final limit = todayStart.add(const Duration(days: 30));

        final rows = (snapshot.data ?? const []).where((row) {
          if (row['status_approve'] != 'Y') {
            return false;
          }

          final expiry = DateTime.tryParse(
            row['masa_berlaku_sampai'] as String? ?? '',
          );

          return expiry != null &&
              !expiry.isBefore(todayStart) &&
              !expiry.isAfter(limit);
        }).toList();

        if (rows.isEmpty) {
          return const Text(
            'Tidak ada dokumen disetujui yang kedaluwarsa dalam 30 hari.',
          );
        }

        return Column(
          children: rows.take(5).map((row) {
            final ownerValue = row['admin_wisata'];

            final owner = ownerValue is Map<String, dynamic>
                ? ownerValue
                : <String, dynamic>{};

            final expiryValue = row['masa_berlaku_sampai'] as String;

            final expiry = DateTime.parse(expiryValue);

            final daysLeft = expiry.difference(todayStart).inDays;

            final id = (row['id_dokumen'] as num?)?.toInt();

            final company =
                owner['nama_lengkap_admin'] as String? ??
                owner['username'] as String? ??
                'Mitra';

            final type = row['jenis_dokumen'] as String? ?? 'Dokumen legalitas';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.description_outlined, color: _blue),
                title: Text(
                  type,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  '$company · berlaku sampai $expiryValue',
                  style: GoogleFonts.manrope(fontSize: 10, color: _muted),
                ),
                trailing: Text(
                  '$daysLeft hari',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _blue,
                  ),
                ),
                onTap: () => _openPermitList(
                  context,
                  initialFilter: 'Akan berakhir',
                  initialPermitId: id == null
                      ? null
                      : 'DOC-${id.toString().padLeft(5, '0')}',
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (SessionManager.adminAccessToken == null) {
      return const LoginScreens();
    }
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _DashboardHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    const SizedBox(height: 18),
                    _SummaryGrid(
                      key: ValueKey(_summaryRevision),
                      loader: widget.dashboardLoader,
                    ),
                    const SizedBox(height: 20),
                    _AuditBanner(
                      onTap: () =>
                          _openPermitList(context, initialFilter: 'Menunggu'),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeading(
                      title: 'Pengajuan Menunggu Verifikasi',
                      badge: 'Supabase',
                      action: 'Semua',
                      onAction: () =>
                          _openPermitList(context, initialFilter: 'Menunggu'),
                    ),
                    const SizedBox(height: 12),
                    _pendingWisataList(),
                    const SizedBox(height: 24),
                    _SectionHeading(
                      title: 'Izin Akan Berakhir',
                      action: 'Prioritas Regulasi',
                      onAction: () => _openPermitList(
                        context,
                        initialFilter: 'Akan berakhir',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _expiringDocumentsList(),
                    const SizedBox(height: 20),
                    const _SyncCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavigator(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) _openMitra(context);
          if (index == 2) _openLicenses(context);
          if (index == 3) _openReport(context);
          if (index == 4) _openProfile(context);
        },
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang, Admin',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ringkasan operasional platform & pengawasan\nkemitraan LokaTrip',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  height: 1.35,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFE1E6FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.insights_rounded, color: _blue, size: 22),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _page,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Row(
        children: [
          Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 14),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOKATRIP ADMIN',
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _blue,
                  letterSpacing: 0.7,
                ),
              ),
              Text(
                'Dashboard',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
            ],
          ),
          const Spacer(),
          AdminNotificationButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotifikasiAdminScreens(),
                ),
              );
            },
            color: _navy,
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatefulWidget {
  final DashboardLoader? loader;

  const _SummaryGrid({super.key, this.loader});

  @override
  State<_SummaryGrid> createState() => _SummaryGridState();
}

class _SummaryGridState extends State<_SummaryGrid> {
  late final Future<Map<String, dynamic>> _summary = _load();

  Future<Map<String, dynamic>> _load() {
    if (widget.loader != null) {
      return widget.loader!();
    }

    final token = SessionManager.adminAccessToken;

    if (token == null) {
      throw const AdminAuthException('Sesi admin tidak tersedia.');
    }

    return AdminAuthService.getDashboard(accessToken: token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _summary,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 288,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Ringkasan admin tidak dapat dimuat: ${snapshot.error}',
              style: GoogleFonts.manrope(fontSize: 11, color: _muted),
            ),
          );
        }
        final data = snapshot.data ?? const <String, dynamic>{};
        String count(String key) =>
            (data[key] as num?)?.toInt().toString() ?? '0';
        final reviews =
            ((data['wisata_menunggu_verifikasi'] as num?)?.toInt() ?? 0) +
            ((data['dokumen_menunggu_verifikasi'] as num?)?.toInt() ?? 0);
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.storefront_outlined,
                    iconColor: Color(0xFF047857),
                    iconBackground: Color(0xFF9BF4D1),
                    badge: 'Data Supabase',
                    badgeColor: Color(0xFFD8F4E9),
                    value: count('total_mitra'),
                    label: 'Total Mitra',
                    note: 'Akun terdaftar',
                    noteIcon: Icons.trending_up_rounded,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.assignment_add,
                    iconColor: Color(0xFFB91C1C),
                    iconBackground: Color(0xFFFFE1DF),
                    badge: 'Perlu review',
                    badgeColor: Color(0xFFFFD8D5),
                    value: '$reviews',
                    label: 'Perlu Review',
                    note: 'Wisata dan dokumen',
                    noteIcon: Icons.assignment_late_outlined,
                    noteRed: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.verified_rounded,
                    iconColor: Color(0xFF123FC4),
                    iconBackground: Color(0xFFDCE2FF),
                    badge: 'Valid',
                    badgeColor: Color(0xFFDCE2FF),
                    value: count('wisata_aktif'),
                    label: 'Wisata Aktif',
                    note: 'Disetujui admin',
                    noteIcon: Icons.verified_user_outlined,
                    noteBlue: true,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.timer_outlined,
                    iconColor: Color(0xFF0369A1),
                    iconBackground: Color(0xFFC9E8FF),
                    badge: '< 30 Hari',
                    badgeColor: Color(0xFFD2EDFF),
                    value: count('dokumen_segera_kedaluwarsa'),
                    label: 'Izin Akan Berakhir',
                    note: 'Dalam 30 hari',
                    noteIcon: Icons.schedule_rounded,
                    noteBlue: true,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String badge;
  final Color badgeColor;
  final String value;
  final String label;
  final String note;
  final IconData noteIcon;
  final bool noteRed;
  final bool noteBlue;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.badge,
    required this.badgeColor,
    required this.value,
    required this.label,
    required this.note,
    required this.noteIcon,
    this.noteRed = false,
    this.noteBlue = false,
  });

  @override
  Widget build(BuildContext context) {
    final noteColor = noteRed
        ? const Color(0xFFB91C1C)
        : noteBlue
        ? _blue
        : const Color(0xFF047857);

    return Container(
      height: 134,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      badge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _muted,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(noteIcon, size: 12, color: noteColor),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: noteColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _AuditBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF2452E8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audit Kilat Mitra',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                Text(
                  'Tinjau dokumen yang menunggu pemeriksaan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Mulai',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: _blue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? badge;
  final String action;
  final VoidCallback onAction;

  const _SectionHeading({
    required this.title,
    this.badge,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD9D5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge!,
              style: GoogleFonts.manrope(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(vertical: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action,
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _blue,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16, color: _blue),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final String partner;
  final String title;
  final String date;
  final String category;
  final String documents;
  final IconData icon;
  final Color imageColor;
  final VoidCallback onPressed;

  const _VerificationCard({
    required this.partner,
    required this.title,
    required this.date,
    required this.category,
    required this.documents,
    required this.icon,
    required this.imageColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: imageColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            partner,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: const Color(0xFF00699C),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8F1FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'â— Menunggu',
                            style: GoogleFonts.manrope(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF075985),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: _muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'â€¢',
                          style: TextStyle(color: Color(0xFFB5B8C2)),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              color: _muted,
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
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                size: 14,
                color: Color(0xFF065F46),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  documents,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _muted,
                  ),
                ),
              ),
              Material(
                color: _blue,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.rule_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Periksa',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpiryAlert extends StatelessWidget {
  final VoidCallback onTap;

  const _ExpiryAlert({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEDEF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFB91C1C),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '8 izin mitra akan berakhir dalam 30 hari.',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                Text(
                  'Perpanjangan berkas diperlukan agar operasional mitra di platform tetap aktif tanpa suspensi.',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    height: 1.35,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.manrope(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: _blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseCard extends StatelessWidget {
  final String company;
  final String title;
  final String detail;
  final String expiry;
  final String daysLeft;
  final double progress;
  final VoidCallback onPressed;

  const _LicenseCard({
    required this.company,
    required this.title,
    required this.detail,
    required this.expiry,
    required this.daysLeft,
    required this.progress,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: _muted,
                      ),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                    Text(
                      detail,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        height: 1.35,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4ECFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: _navy),
                    const SizedBox(width: 3),
                    Text(
                      daysLeft,
                      style: GoogleFonts.manrope(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE3EDFF),
              color: const Color(0xFF00729D),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Kedaluwarsa: $expiry',
                  style: GoogleFonts.manrope(fontSize: 10, color: _muted),
                ),
              ),
              TextButton.icon(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFDDE8FF),
                  foregroundColor: _blue,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                icon: const Icon(Icons.description_outlined, size: 13),
                label: Text(
                  'Tinjau Izin',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  const _SyncCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border, width: 0.6),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF89F2CD),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.cloud_done_outlined,
              size: 21,
              color: Color(0xFF047857),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinkronisasi Server OSS Aman',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                Text(
                  'Pemutakhiran izin otomatis terakhir: 12 menit lalu',
                  maxLines: 2,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    height: 1.3,
                    color: _muted,
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
