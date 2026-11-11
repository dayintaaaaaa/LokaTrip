import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_color.dart';
import 'pengaturan_akun_admin_screens.dart';

enum PreferensiAdminSection { notifications, security, help, about }

class PreferensiKontrolAdminScreens extends StatefulWidget {
  const PreferensiKontrolAdminScreens({super.key, required this.section});

  final PreferensiAdminSection section;

  @override
  State<PreferensiKontrolAdminScreens> createState() =>
      _PreferensiKontrolAdminScreensState();
}

class _PreferensiKontrolAdminScreensState
    extends State<PreferensiKontrolAdminScreens> {
  late final Map<String, bool> _notificationSettings = {
    'Push notification': true,
    'Eskalasi perizinan': true,
    'Ringkasan aktivitas': false,
    'Broadcast platform': true,
  };

  String get _title => switch (widget.section) {
    PreferensiAdminSection.notifications => 'Notifikasi',
    PreferensiAdminSection.security => 'Keamanan',
    PreferensiAdminSection.help => 'Bantuan & SOP',
    PreferensiAdminSection.about => 'Tentang LokaTrip',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: switch (widget.section) {
                  PreferensiAdminSection.notifications =>
                    _buildNotifications(),
                  PreferensiAdminSection.security => _buildSecurity(),
                  PreferensiAdminSection.help => _buildHelp(),
                  PreferensiAdminSection.about => _buildAbout(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Kembali ke profil',
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColor.hitam,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _title,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColor.hitam,
              ),
            ),
          ),
          const Icon(Icons.shield_rounded, color: AppColor.ungu, size: 22),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _introCard(
          icon: Icons.notifications_active_outlined,
          title: 'Atur pemberitahuan admin',
          description:
              'Pilih informasi yang ingin ditampilkan selama menggunakan konsol.',
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Saluran dan aktivitas',
          child: Column(
            children: _notificationSettings.entries.map((entry) {
              return SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  entry.key,
                  style: _bodyStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _notificationDescription(entry.key),
                  style: _mutedStyle(),
                ),
                value: entry.value,
                activeTrackColor: AppColor.ungu,
                onChanged: (value) => setState(
                  () => _notificationSettings[entry.key] = value,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        _localOnlyNotice(),
      ],
    );
  }

  String _notificationDescription(String name) => switch (name) {
    'Push notification' => 'Pemberitahuan penting di konsol admin.',
    'Eskalasi perizinan' => 'Perubahan status dan tenggat pemeriksaan izin.',
    'Ringkasan aktivitas' => 'Rekap aktivitas administrator secara berkala.',
    _ => 'Pengumuman dan informasi operasional platform.',
  };

  Widget _buildSecurity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _introCard(
          icon: Icons.security_outlined,
          title: 'Keamanan akun administrator',
          description:
              'Tinjau status keamanan sebelum melanjutkan aktivitas pengelolaan platform.',
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Status perlindungan',
          child: Column(
            children: [
              _statusRow(
                icon: Icons.verified_user_outlined,
                title: 'Koneksi konsol',
                detail: 'TLS 1.3 ditampilkan sebagai konfigurasi aplikasi.',
                status: 'Informasi',
                statusColor: const Color(0xFF525EA7),
                statusBackground: const Color(0xFFEEF0FF),
              ),
              const Divider(height: 24),
              _statusRow(
                icon: Icons.phonelink_lock_outlined,
                title: 'Autentikasi dua faktor',
                detail: 'Belum terhubung ke layanan autentikasi.',
                status: 'Belum tersedia',
                statusColor: const Color(0xFFB45309),
                statusBackground: const Color(0xFFFFF3D6),
              ),
              const Divider(height: 24),
              _statusRow(
                icon: Icons.devices_outlined,
                title: 'Sesi perangkat',
                detail: 'Pengelolaan sesi memerlukan koneksi ke server.',
                status: 'Belum tersedia',
                statusColor: const Color(0xFFB45309),
                statusBackground: const Color(0xFFFFF3D6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _localOnlyNotice(),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PengaturanAkunAdminScreens(),
            ),
          ),
          icon: const Icon(Icons.manage_accounts_outlined),
          label: const Text('Buka pengaturan akun'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.ungu,
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: AppColor.ungu.withValues(alpha: 0.35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelp() {
    final guides = <({String title, String detail})>[
      (
        title: 'Memeriksa pengajuan mitra',
        detail:
            'Buka menu Mitra atau Perizinan, cocokkan data pengajuan dengan dokumen yang diunggah, lalu gunakan tindakan tinjau yang sesuai. Jika ada berkas yang tidak jelas, minta perbaikan sebelum menyetujui.',
      ),
      (
        title: 'Menerbitkan izin operasional',
        detail:
            'Pastikan identitas mitra dan persyaratan izin sudah diperiksa. Catat keputusan pemeriksaan pada pengajuan dan terbitkan izin hanya setelah seluruh persyaratan dinyatakan lengkap.',
      ),
      (
        title: 'Menangani dokumen kedaluwarsa',
        detail:
            'Periksa tanggal berlaku dokumen, hubungi mitra melalui kanal resmi, dan tahan proses yang membutuhkan dokumen aktif sampai pembaruan diterima dan diverifikasi.',
      ),
      (
        title: 'Menjaga jejak audit',
        detail:
            'Lakukan perubahan melalui konsol admin dan berikan alasan yang jelas saat menolak atau menangguhkan pengajuan. Data audit pada rancangan ini belum bersumber dari server.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _introCard(
          icon: Icons.menu_book_outlined,
          title: 'Panduan operasional',
          description:
              'Ringkasan langkah kerja untuk pemeriksaan mitra dan perizinan.',
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Prosedur standar',
          child: Column(
            children: guides
                .map(
                  (guide) => ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 14),
                    title: Text(
                      guide.title,
                      style: _bodyStyle(fontWeight: FontWeight.w700),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(guide.detail, style: _mutedStyle()),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        _localOnlyNotice(),
      ],
    );
  }

  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _introCard(
          icon: Icons.travel_explore_rounded,
          title: 'LokaTrip Admin',
          description:
              'Konsol administrasi untuk membantu pengelolaan mitra wisata dan perizinan.',
        ),
        const SizedBox(height: 14),
        _sectionCard(
          title: 'Informasi aplikasi',
          child: Column(
            children: [
              _informationRow('Produk', 'LokaTrip Admin'),
              _informationRow('Versi tampilan', '2.4.0'),
              _informationRow('Peran', 'Platform Administrator'),
              _informationRow('Status data', 'Mode rancangan / lokal'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _localOnlyNotice(),
      ],
    );
  }

  Widget _introCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return _sectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColor.ungu, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _bodyStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(description, style: _mutedStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({String? title, required Widget child}) {
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
          if (title != null) ...[
            Text(title, style: _bodyStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }

  Widget _statusRow({
    required IconData icon,
    required String title,
    required String detail,
    required String status,
    required Color statusColor,
    required Color statusBackground,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColor.ungu, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _bodyStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(detail, style: _mutedStyle()),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: statusBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _informationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: _mutedStyle())),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: _bodyStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _localOnlyNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE3A3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: Color(0xFF9A6700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Fitur ini masih berupa rancangan lokal dan belum tersinkron dengan server.',
              style: GoogleFonts.manrope(
                fontSize: 11,
                height: 1.45,
                color: const Color(0xFF805600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _bodyStyle({FontWeight fontWeight = FontWeight.w500}) =>
      GoogleFonts.manrope(
        fontSize: 13,
        height: 1.4,
        fontWeight: fontWeight,
        color: AppColor.hitam,
      );

  TextStyle _mutedStyle() => GoogleFonts.manrope(
    fontSize: 11,
    height: 1.5,
    color: AppColor.abu,
  );
}
