import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/mitra_theme.dart';

import '../../core/api_client.dart';
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
  bool _loadingProfile = true;
  bool _isBalanceVisible = true;
  bool _credentialUpdating = false;
  Map<String, dynamic> _profile = const {};
  Map<String, dynamic> _summary = const {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await SessionManager.currentMitraToken();
      if (token == null) {
        throw const ApiException(
          'Sesi mitra tidak ditemukan. Silakan masuk kembali.',
        );
      }
      final results = await Future.wait([
        MitraApi.profile(token),
        MitraApi.ringkasan(token),
      ]);
      final result = results[0];
      final profile = result['mitra'];
      if (profile is! Map<String, dynamic>) {
        throw const ApiException('Data profil mitra tidak valid.');
      }
      final summary = results[1]['ringkasan'];
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _summary = summary is Map<String, dynamic> ? summary : const {};
        _loadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingProfile = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  String get _partnerId {
    final id = _profile['id_mitra'];
    if (id == null) return '-';
    return 'MIT-${id.toString().padLeft(5, '0')}';
  }

  Future<void> _logout() async {
    final token = await SessionManager.currentMitraToken();
    try {
      if (token != null) await MitraApi.logout(token);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sesi lokal diakhiri: $error')));
      }
    }
    await SessionManager.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreens()),
      (_) => false,
    );
  }

  void _copyPartnerId() {
    Clipboard.setData(ClipboardData(text: _partnerId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ID Kemitraan $_partnerId berhasil disalin.'),
        duration: Duration(seconds: 2),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(),
                          const SizedBox(height: 16),
                          if (_loadingProfile)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else ...[
                            _buildPartnerOverviewCard(),
                            const SizedBox(height: 20),
                            _buildFinancialWalletSection(),
                            const SizedBox(height: 20),
                            _buildCompanyPicSection(),
                            const SizedBox(height: 20),
                            _buildSecuritySection(),
                          ],
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
                onPressed: _loadingProfile ? null : _loadProfile,
                tooltip: 'Muat ulang data profil',
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
            ],
          ),
          const SizedBox(width: 8),
          // Profile Avatar
          const CircleAvatar(
            radius: 18,
            backgroundColor: MitraPalette.primary,
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
            color: MitraPalette.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MitraPalette.primaryBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 13,
                color: MitraPalette.primary,
              ),
              const SizedBox(width: 5),
              Text(
                'PORTAL MITRA LOKATRIP',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: MitraPalette.primary,
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
            color: MitraPalette.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lihat dan perbarui informasi akun mitra yang tersimpan di LokaTrip.',
          style: GoogleFonts.manrope(fontSize: 12, color: MitraPalette.muted),
        ),
      ],
    );
  }

  String _formatRupiah(num amount) {
    final digits = amount.round().toString();
    final result = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) result.write('.');
      result.write(digits[index]);
    }
    return 'Rp $result';
  }

  Widget _buildFinancialWalletSection() {
    final paymentValue = (_summary['nilai_pembayaran_berhasil'] as num?) ?? 0;
    final paidOrders = (_summary['pesanan_terbayar'] as num?)?.toInt() ?? 0;
    final destinationCount =
        (_summary['total_destinasi'] as num?)?.toInt() ?? 0;
    final approvedDestinations =
        (_summary['destinasi_disetujui'] as num?)?.toInt() ?? 0;
    final documentCount = (_summary['total_dokumen'] as num?)?.toInt() ?? 0;
    final approvedDocuments =
        (_summary['dokumen_disetujui'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MitraPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: MitraPalette.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ringkasan Mitra',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: MitraPalette.ink,
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _isBalanceVisible = !_isBalanceVisible),
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                tooltip: _isBalanceVisible
                    ? 'Sembunyikan nilai'
                    : 'Tampilkan nilai',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nilai tiket terbayar (biaya layanan dikecualikan)',
            style: GoogleFonts.manrope(fontSize: 11, color: MitraPalette.muted),
          ),
          const SizedBox(height: 3),
          Text(
            _isBalanceVisible ? _formatRupiah(paymentValue) : 'Rp ••••••••',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: MitraPalette.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$paidOrders pesanan telah dibayar',
            style: GoogleFonts.manrope(fontSize: 11, color: MitraPalette.muted),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  'Destinasi',
                  '$approvedDestinations / $destinationCount',
                  Icons.landscape_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryStat(
                  'Legalitas',
                  '$approvedDocuments / $documentCount',
                  Icons.verified_user_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Nilai ini hanya bagian tiket setelah diskon. Biaya layanan Rp20.000 dicatat untuk LokaTrip; angka ini bukan saldo pencairan.',
            style: GoogleFonts.manrope(fontSize: 10, color: MitraPalette.muted),
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String title, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: MitraPalette.canvas,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: MitraPalette.line),
    ),
    child: Row(
      children: [
        Icon(icon, color: MitraPalette.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: MitraPalette.muted,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: MitraPalette.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildCompanyPicSection() {
    final rows = <(String, String, IconData)>[
      (
        'Nama mitra / PIC',
        (_profile['nama_lengkap_admin'] as String?) ?? '-',
        Icons.business_outlined,
      ),
      (
        'Username',
        (_profile['username'] as String?) ?? '-',
        Icons.alternate_email,
      ),
      (
        'Email akun',
        (_profile['email'] as String?) ?? '-',
        Icons.email_outlined,
      ),
      (
        'Telepon operasional',
        (_profile['no_telephone'] as String?) ?? '-',
        Icons.phone_outlined,
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              const Icon(
                Icons.business_rounded,
                size: 18,
                color: MitraPalette.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Informasi Badan Usaha & PIC',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: MitraPalette.ink,
                  ),
                ),
              ),
              _statusPill(
                (_summary['status_mitra'] as String?) ?? 'menunggu_verifikasi',
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < rows.length; index++) ...[
            _companyInfoRow(
              icon: rows[index].$3,
              label: rows[index].$1,
              value: rows[index].$2,
            ),
            if (index < rows.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: MitraPalette.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const UbahDataMitraScreen()),
              );
              if (updated == true) _loadProfile();
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
    );
  }

  Widget _buildSecuritySection() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(MitraMetrics.cardRadius),
      border: Border.all(color: MitraPalette.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: MitraPalette.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.security_outlined,
                size: 19,
                color: MitraPalette.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keamanan akun',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: MitraPalette.ink,
                    ),
                  ),
                  Text(
                    'Atur email login dan kata sandi portal mitra.',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: MitraPalette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _securityActionRow(
          icon: Icons.email_outlined,
          label: 'Email login',
          value: (_profile['email'] as String?) ?? 'Email tidak tersedia',
          buttonLabel: 'Ubah',
          onPressed: _credentialUpdating ? null : _showChangeEmailDialog,
        ),
        const Divider(height: 24),
        _securityActionRow(
          icon: Icons.lock_outline_rounded,
          label: 'Password',
          value: 'Perbarui kata sandi akun Anda',
          buttonLabel: 'Ubah',
          onPressed: _credentialUpdating ? null : _showChangePasswordDialog,
        ),
        if (_credentialUpdating) ...[
          const SizedBox(height: 14),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    ),
  );

  Widget _securityActionRow({
    required IconData icon,
    required String label,
    required String value,
    required String buttonLabel,
    required VoidCallback? onPressed,
  }) => Row(
    children: [
      Icon(icon, size: 19, color: MitraPalette.muted),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: MitraPalette.muted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: MitraPalette.ink,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      TextButton(onPressed: onPressed, child: Text(buttonLabel)),
    ],
  );

  Future<void> _showChangePasswordDialog() async {
    final formKey = GlobalKey<FormState>();
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    var obscureCurrent = true;
    var obscureNext = true;
    var obscureConfirm = true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          title: Text(
            'Ubah password',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: current,
                  obscureText: obscureCurrent,
                  decoration: _credentialInput(
                    'Password saat ini',
                    obscureCurrent,
                    () =>
                        setDialogState(() => obscureCurrent = !obscureCurrent),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Masukkan password saat ini.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: next,
                  obscureText: obscureNext,
                  decoration: _credentialInput(
                    'Password baru',
                    obscureNext,
                    () => setDialogState(() => obscureNext = !obscureNext),
                  ),
                  validator: (value) => value == null || value.length < 8
                      ? 'Password minimal 8 karakter.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirm,
                  obscureText: obscureConfirm,
                  decoration: _credentialInput(
                    'Ulangi password baru',
                    obscureConfirm,
                    () =>
                        setDialogState(() => obscureConfirm = !obscureConfirm),
                  ),
                  validator: (value) => value != next.text
                      ? 'Konfirmasi password belum cocok.'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Simpan password'),
            ),
          ],
        ),
      ),
    );
    if (result == true && mounted) {
      await _runCredentialUpdate(
        () => MitraApi.changePassword(
          currentPassword: current.text,
          newPassword: next.text,
        ),
        successMessage: 'Password berhasil diperbarui.',
      );
    }
    current.dispose();
    next.dispose();
    confirm.dispose();
  }

  Future<void> _showChangeEmailDialog() async {
    final formKey = GlobalKey<FormState>();
    final email = TextEditingController();
    final password = TextEditingController();
    final currentEmail = (_profile['email'] as String?)?.trim().toLowerCase();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(
          'Ubah email login',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email baru',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) {
                  final candidate = value?.trim() ?? '';
                  if (!RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  ).hasMatch(candidate)) {
                    return 'Masukkan alamat email yang valid.';
                  }
                  if (candidate.toLowerCase() == currentEmail) {
                    return 'Gunakan email yang berbeda.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password saat ini',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan password saat ini.'
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                'Selesaikan konfirmasi email, lalu masuk kembali memakai email baru.',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  height: 1.4,
                  color: MitraPalette.muted,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Kirim konfirmasi'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await _runCredentialUpdate(
        () => MitraApi.changeEmail(
          currentPassword: password.text,
          newEmail: email.text,
        ),
        successMessage:
            'Tautan konfirmasi email sudah dikirim. Selesaikan konfirmasi untuk mengaktifkan email baru.',
      );
    }
    email.dispose();
    password.dispose();
  }

  InputDecoration _credentialInput(
    String label,
    bool obscure,
    VoidCallback onToggle,
  ) => InputDecoration(
    labelText: label,
    suffixIcon: IconButton(
      tooltip: obscure ? 'Tampilkan password' : 'Sembunyikan password',
      onPressed: onToggle,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    ),
  );

  Future<void> _runCredentialUpdate(
    Future<void> Function() update, {
    required String successMessage,
  }) async {
    setState(() => _credentialUpdating = true);
    try {
      await update();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _credentialUpdating = false);
    }
  }

  Widget _companyInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: MitraPalette.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: MitraPalette.primary),
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
                color: MitraPalette.muted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: MitraPalette.ink,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _statusPill(String status) {
    final active = status == 'aktif';
    final color = active ? const Color(0xFF15803D) : const Color(0xFFB45309);
    final label = switch (status) {
      'aktif' => 'Aktif',
      'ditolak' => 'Perlu perbaikan',
      'ditangguhkan' => 'Ditangguhkan',
      _ => 'Menunggu verifikasi',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPartnerOverviewCard() {
    final name = (_profile['nama_lengkap_admin'] as String?)?.trim();
    final initials = (name?.isNotEmpty == true ? name! : 'M')
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MitraPalette.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: MitraPalette.primary,
            child: Text(
              initials,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name?.isNotEmpty == true ? name! : 'Nama mitra belum diatur',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: MitraPalette.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  (_profile['email'] as String?) ?? 'Email tidak tersedia',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: MitraPalette.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _statusPill(
                      (_summary['status_mitra'] as String?) ??
                          'menunggu_verifikasi',
                    ),
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        _partnerId,
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      avatar: const Icon(Icons.copy_rounded, size: 13),
                      onPressed: _copyPartnerId,
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

  Widget _buildLogoutButton() => OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFDC2626),
      backgroundColor: const Color(0xFFFEF2F2),
      minimumSize: const Size.fromHeight(48),
      side: const BorderSide(color: Color(0xFFFEE2E2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Keluar dari Akun Mitra'),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari Portal Mitra LokaTrip?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya, Keluar'),
            ),
          ],
        ),
      );
      if (confirmed == true) await _logout();
    },
    icon: const Icon(Icons.logout_rounded, size: 18),
    label: Text(
      'Keluar dari Akun Mitra',
      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700),
    ),
  );

  Widget _buildFooter() => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 13,
            color: MitraPalette.primary,
          ),
          const SizedBox(width: 5),
          Text(
            'Portal Mitra LokaTrip',
            style: GoogleFonts.manrope(fontSize: 10, color: MitraPalette.muted),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Text(
        'Hak Cipta © 2026 PT LokaTrip Nusantara Terpadu.',
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(fontSize: 9, color: const Color(0xFF94A3B8)),
      ),
    ],
  );
}
