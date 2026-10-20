import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../widgets/admin_bottom_navigator.dart';

class PengaturanAkunAdminScreens extends StatefulWidget {
  const PengaturanAkunAdminScreens({super.key});

  @override
  State<PengaturanAkunAdminScreens> createState() =>
      _PengaturanAkunAdminScreensState();
}

class _PengaturanAkunAdminScreensState
    extends State<PengaturanAkunAdminScreens> {
  // ── controllers ──────────────────────────────────────────────────────────
  final _namaController =
      TextEditingController(text: 'Administrator Utama');
  final _emailController =
      TextEditingController(text: 'admin@lokatrip.id');
  final _teleponController =
      TextEditingController(text: '+62 812-9842-1100');
  final _departemenController = TextEditingController(
      text: 'Divisi Kelaikan & Regulasi Operasional Dishub LokaTrip');
  final _kantorController = TextEditingController(
      text: 'Kantor Wilayah Operasional Jakarta Pusat');

  String _bahasa = 'Bahasa Indonesia (Standar Dinas)';
  String _zona = 'Asia/Jakarta (WIB) · UTC+07:00';

  bool _isSaving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _departemenController.dispose();
    _kantorController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    setState(() => _isSaving = true);
    // TODO: kirim ke backend
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Perubahan berhasil disimpan',
              style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildSubHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: 20),
                    _buildDataPegawaiSection(),
                    const SizedBox(height: 16),
                    _buildPreferensiSection(),
                    const SizedBox(height: 24),
                    _buildSimpanButton(),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Batal / Kembali ke Profil',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColor.abu,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavigator(
        currentIndex: 4,
        onTap: (_) {},
      ),
    );
  }

  // ─── Top Bar (sama seperti profil) ──────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColor.latar,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/LokaTrip-logo-no-van.png',
                    height: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ADMIN',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColor.ungu,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Profil',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Bell dengan badge merah
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 24,
                  color: AppColor.hitam,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // Avatar icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColor.ungu,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                size: 20, color: AppColor.putih),
          ),
        ],
      ),
    );
  }

  // ─── Sub Header ──────────────────────────────────────────────────────────
  Widget _buildSubHeader(BuildContext context) {
    return Container(
      color: AppColor.latar,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          // Tombol back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColor.putih,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.hitam.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColor.hitam),
            ),
          ),
          const SizedBox(width: 12),
          // Judul
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan Akun',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
              Text(
                'KREDENSIAL & DINAS',
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColor.abu,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Tombol Simpan
          GestureDetector(
            onTap: _isSaving ? null : _simpan,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColor.ungu,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isSaving
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.putih,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline,
                          size: 14, color: AppColor.putih),
                  const SizedBox(width: 6),
                  Text(
                    'Simpan',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.putih,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Avatar Section ──────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              // Avatar lingkaran
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.ungu.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColor.ungu.withValues(alpha: 0.3),
                    width: 2.5,
                  ),
                ),
                child: const Icon(Icons.person_rounded,
                    size: 46, color: AppColor.ungu),
              ),
              // Online dot
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColor.putih, width: 2),
                  ),
                ),
              ),
              // Camera icon
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // TODO: ganti foto
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColor.ungu,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColor.putih, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 14, color: AppColor.putih),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Platform Administrator chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded,
                    size: 11, color: AppColor.ungu),
                const SizedBox(width: 4),
                Text(
                  'Platform Administrator',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.ungu,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administrator Utama',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColor.hitam,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NIP: ADM-2024-0891',
                style: GoogleFonts.manrope(
                    fontSize: 11, color: AppColor.abu),
              ),
              const SizedBox(width: 8),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Sesi Aktif',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Data Pegawai & Kontak Dinas ─────────────────────────────────────────
  Widget _buildDataPegawaiSection() {
    return _sectionCard(
      headerIcon: Icons.badge_outlined,
      headerLabel: 'Data Pegawai & Kontak Dinas',
      headerBadge: 'RESMI',
      headerBadgeColor: const Color(0xFF3B82F6),
      child: Column(
        children: [
          // Nama Lengkap
          _fieldLabel('Nama Lengkap Sesuai SK'),
          _inputField(
            controller: _namaController,
            prefixIcon: Icons.person_outline,
            hint: 'Nama lengkap sesuai SK',
          ),
          const SizedBox(height: 14),

          // Email
          _fieldLabelWithBadge(
            'Email Kedinasan',
            badgeText: '✓ Terverifikasi',
            badgeBg: const Color(0xFFDCFCE7),
            badgeColor: const Color(0xFF16A34A),
          ),
          _inputField(
            controller: _emailController,
            prefixIcon: Icons.mail_outline_rounded,
            hint: 'email@lokatrip.id',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          // Telepon
          _fieldLabel('Nomor Telepon Dinas Aktif'),
          _inputField(
            controller: _teleponController,
            prefixIcon: Icons.phone_outlined,
            hint: '+62 ...',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),

          // Departemen
          _fieldLabel('Departemen / Unit Penugasan'),
          _inputField(
            controller: _departemenController,
            prefixIcon: Icons.domain_outlined,
            hint: 'Nama departemen',
            maxLines: 2,
          ),
          const SizedBox(height: 14),

          // Kantor Wilayah
          _fieldLabel('Kantor Wilayah / Hub Operasional'),
          _inputField(
            controller: _kantorController,
            prefixIcon: Icons.location_on_outlined,
            hint: 'Nama kantor wilayah',
          ),
        ],
      ),
    );
  }

  // ─── Preferensi Sistem & Regional ────────────────────────────────────────
  Widget _buildPreferensiSection() {
    return _sectionCard(
      headerIcon: Icons.tune_rounded,
      headerLabel: 'Preferensi Sistem & Regional',
      child: Column(
        children: [
          // Bahasa
          _fieldLabel('Bahasa Antarmuka Konsol'),
          _dropdownField(
            value: _bahasa,
            prefixIcon: Icons.language_rounded,
            items: const [
              'Bahasa Indonesia (Standar Dinas)',
              'English (International)',
            ],
            onChanged: (val) => setState(() => _bahasa = val!),
          ),
          const SizedBox(height: 14),

          // Zona Waktu
          _fieldLabel('Zona Waktu Operasional'),
          _dropdownField(
            value: _zona,
            prefixIcon: Icons.schedule_rounded,
            items: const [
              'Asia/Jakarta (WIB) · UTC+07:00',
              'Asia/Makassar (WITA) · UTC+08:00',
              'Asia/Jayapura (WIT) · UTC+09:00',
            ],
            onChanged: (val) => setState(() => _zona = val!),
          ),
        ],
      ),
    );
  }

  // ─── Simpan Button ────────────────────────────────────────────────────────
  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _simpan,
        icon: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColor.putih),
              )
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: AppColor.putih,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ─── Shared Helpers ───────────────────────────────────────────────────────

  Widget _sectionCard({
    required IconData headerIcon,
    required String headerLabel,
    String? headerBadge,
    Color? headerBadgeColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(headerIcon, size: 16, color: AppColor.ungu),
              const SizedBox(width: 6),
              Text(
                headerLabel,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
              if (headerBadge != null) ...[
                const Spacer(),
                Text(
                  headerBadge,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: headerBadgeColor ?? AppColor.ungu,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColor.hitam.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _fieldLabelWithBadge(
    String label, {
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColor.hitam.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData prefixIcon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.manrope(fontSize: 12, color: AppColor.hitam),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(prefixIcon, size: 16, color: AppColor.abu),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        filled: true,
        fillColor: AppColor.latar,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: AppColor.abu.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColor.ungu, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required IconData prefixIcon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.latar,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.unfold_more_rounded,
              size: 18, color: AppColor.abu),
          style: GoogleFonts.manrope(fontSize: 12, color: AppColor.hitam),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        Icon(prefixIcon, size: 15, color: AppColor.abu),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e,
                              style: GoogleFonts.manrope(fontSize: 12)),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
