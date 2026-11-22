import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/admin_auth_service.dart';
import '../../core/session_manager.dart';
import '../../widgets/admin_bottom_navigator.dart';
import '../../widgets/admin_notification_button.dart';
import 'dashboard_admin_screens.dart';
import 'laporan_admin_screens.dart';
import 'mitra_admin_screens.dart';
import 'notifikasi_admin_screens.dart';
import 'perizinan_admin_screens.dart';

class PengaturanAkunAdminScreens extends StatefulWidget {
  const PengaturanAkunAdminScreens({super.key});

  @override
  State<PengaturanAkunAdminScreens> createState() =>
      _PengaturanAkunAdminScreensState();
}

class _PengaturanAkunAdminScreensState
    extends State<PengaturanAkunAdminScreens> {
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  AdminProfile? _profile;
  String? _loadError;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final token = SessionManager.adminAccessToken;
      if (token == null) {
        throw const AdminAuthException(
          'Sesi admin tidak tersedia. Silakan login kembali.',
        );
      }
      final profile = await AdminAuthService.getProfile(accessToken: token);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loadError = null;
        _isLoading = false;
        _setControllers(profile);
      });
    } on AdminAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    }
  }

  void _setControllers(AdminProfile profile) {
    _namaController.text = profile.fullName;
    _usernameController.text = profile.username;
    _emailController.text = profile.email;
    _teleponController.text = profile.phone ?? '';
  }

  Future<void> _simpan() async {
    final username = _usernameController.text.trim();
    final fullName = _namaController.text.trim();
    if (username.isEmpty || fullName.isEmpty) {
      _showMessage('Nama lengkap dan username wajib diisi.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = SessionManager.adminAccessToken;
      if (token == null) {
        throw const AdminAuthException(
          'Sesi admin tidak tersedia. Silakan login kembali.',
        );
      }
      final updated = await AdminAuthService.updateProfile(
        accessToken: token,
        username: username,
        fullName: fullName,
        phone: _teleponController.text.trim().isEmpty
            ? null
            : _teleponController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _setControllers(updated);
      });
      _showMessage('Perubahan berhasil disimpan.');
    } on AdminAuthException catch (error) {
      if (mounted) _showMessage(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? const Color(0xFFDC2626)
              : const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
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
                    if (_loadError != null) ...[
                      Text(
                        _loadError!,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _buildDataPegawaiSection(),
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
        onTap: (index) {
          final page = switch (index) {
            0 => const DashboardAdminScreens(),
            1 => const MitraAdminScreens(),
            2 => const PerizinanAdminScreens(),
            3 => const LaporanAdminScreens(),
            _ => null,
          };
          if (page != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          }
        },
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
          AdminNotificationButton(
            color: AppColor.hitam,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotifikasiAdminScreens()),
            ),
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
            child: const Icon(
              Icons.person_rounded,
              size: 20,
              color: AppColor.putih,
            ),
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColor.hitam,
              ),
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
            onTap: _isSaving || _isLoading || _profile == null ? null : _simpan,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      : const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppColor.putih,
                        ),
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
                child: const Icon(
                  Icons.person_rounded,
                  size: 46,
                  color: AppColor.ungu,
                ),
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
                    border: Border.all(color: AppColor.putih, width: 2),
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
                      border: Border.all(color: AppColor.putih, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: AppColor.putih,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Platform Administrator chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_rounded,
                  size: 11,
                  color: AppColor.ungu,
                ),
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
            _profile?.fullName ??
                (_isLoading ? 'Memuat profil...' : 'Profil admin'),
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
                _profile == null ? '' : '@${_profile!.username}',
                style: GoogleFonts.manrope(fontSize: 11, color: AppColor.abu),
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
      headerLabel: 'Profil Administrator',
      child: Column(
        children: [
          // Nama Lengkap
          _fieldLabel('Nama Lengkap'),
          _inputField(
            controller: _namaController,
            prefixIcon: Icons.person_outline,
            hint: 'Nama lengkap sesuai SK',
            enabled: !_isLoading && _profile != null && !_isSaving,
          ),
          const SizedBox(height: 14),

          _fieldLabel('Username'),
          _inputField(
            controller: _usernameController,
            prefixIcon: Icons.alternate_email_rounded,
            hint: 'Username admin',
            enabled: !_isLoading && _profile != null && !_isSaving,
          ),
          const SizedBox(height: 14),

          _fieldLabel('Email akun'),
          _inputField(
            controller: _emailController,
            prefixIcon: Icons.mail_outline_rounded,
            hint: 'Email Supabase Auth',
            keyboardType: TextInputType.emailAddress,
            enabled: _profile != null,
            readOnly: true,
          ),
          const SizedBox(height: 14),

          _fieldLabel('Nomor Telepon'),
          _inputField(
            controller: _teleponController,
            prefixIcon: Icons.phone_outlined,
            hint: '+62 ...',
            keyboardType: TextInputType.phone,
            enabled: !_isLoading && _profile != null && !_isSaving,
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
        onPressed: _isSaving || _isLoading || _profile == null ? null : _simpan,
        icon: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.putih,
                ),
              )
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
          style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700),
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

  Widget _inputField({
    required TextEditingController controller,
    required IconData prefixIcon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      style: GoogleFonts.manrope(fontSize: 12, color: AppColor.hitam),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(prefixIcon, size: 16, color: AppColor.abu),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        filled: true,
        fillColor: AppColor.latar,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColor.abu.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColor.ungu, width: 1.5),
        ),
      ),
    );
  }
}
