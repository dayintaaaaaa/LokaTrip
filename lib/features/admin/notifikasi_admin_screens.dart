import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/desktop_notification_service.dart';
import 'dashboard_admin_screens.dart';
import 'laporan_admin_screens.dart';
import 'mitra_admin_screens.dart';
import 'perizinan_admin_screens.dart';
import 'profil_screens.dart';

const _blue = Color(0xFF1D4ED8);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF475569);
const _background = Color(0xFFF5F7FF);

class NotifikasiAdminScreens extends StatefulWidget {
  const NotifikasiAdminScreens({super.key});

  @override
  State<NotifikasiAdminScreens> createState() => _NotifikasiAdminScreensState();
}

class _NotifikasiAdminScreensState extends State<NotifikasiAdminScreens> {
  final _items = _notifications();
  var _category = 'Semua';
  var _desktopAllowed = false;
  var _busy = true;
  String? _error;

  int get _unread => _items.where((item) => !item.read).length;
  List<_Notification> get _visible => _category == 'Semua'
      ? _items
      : _items.where((item) => item.category == _category).toList();

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final enabled = await DesktopNotificationService.isEnabled();
      if (mounted) {
        setState(() => _desktopAllowed = enabled);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to load desktop notification preference: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() => _error = 'Pengaturan notifikasi gagal dimuat.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setDesktopAllowed(bool value) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await DesktopNotificationService.setEnabled(value);
      if (!mounted) return;
      setState(() => _desktopAllowed = value);
      if (value) await _sendTest();
    } catch (error, stackTrace) {
      debugPrint('Failed to update desktop notification preference: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _error = error is StateError
              ? error.message
              : 'Pengaturan notifikasi tidak dapat disimpan.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendTest() async {
    try {
      await DesktopNotificationService.show(
        id: 7001,
        title: 'Notifikasi desktop aktif',
        body: 'Pembaruan LokaTrip Admin akan muncul di desktop ini.',
      );
      if (mounted) _message('Notifikasi uji dikirim ke desktop.');
    } catch (error, stackTrace) {
      debugPrint('Failed to show desktop notification: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        _message('Periksa izin notifikasi LokaTrip di pengaturan Windows.');
      }
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _openAdmin(int index) {
    final page = switch (index) {
      0 => const DashboardAdminScreens(),
      1 => const MitraAdminScreens(),
      2 => const PerizinanAdminScreens(),
      3 => const LaporanAdminScreens(),
      4 => const ProfilAdminScreens(),
      _ => null,
    };
    if (page == null) {
      _message('Halaman ini belum tersedia.');
      return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1320),
                      child: Padding(
                        padding: EdgeInsets.all(wide ? 32 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _title(),
                            const SizedBox(height: 22),
                            _filters(),
                            const SizedBox(height: 18),
                            Expanded(
                              child: wide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _list()),
                                        const SizedBox(width: 20),
                                        SizedBox(
                                          width: 290,
                                          child: _settingsCard(),
                                        ),
                                      ],
                                    )
                                  : _list(showSettings: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    color: Colors.white,
    child: Row(
      children: [
        Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 22),
        const SizedBox(width: 10),
        Text(
          'LOKATRIP ADMIN',
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _blue,
            letterSpacing: 0.6,
          ),
        ),
        const Spacer(),
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFFE0E7FF),
          child: Icon(Icons.person_outline, color: _blue),
        ),
      ],
    ),
  );

  Widget _title() => Row(
    children: [
      IconButton.filledTonal(
        tooltip: 'Kembali',
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Notifikasi',
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                if (_unread > 0) ...[
                  const SizedBox(width: 10),
                  _badge('$_unread Baru', _blue),
                ],
              ],
            ),
            Text(
              'Pusat update status mitra dan sistem',
              style: GoogleFonts.manrope(color: _muted, fontSize: 13),
            ),
          ],
        ),
      ),
      OutlinedButton.icon(
        onPressed: _unread == 0
            ? null
            : () => setState(() {
                for (final item in _items) {
                  item.read = true;
                }
              }),
        icon: const Icon(Icons.done_all, size: 17),
        label: const Text('Tandai dibaca'),
      ),
    ],
  );

  Widget _filters() {
    const categories = ['Semua', 'Mitra', 'Perizinan', 'Sistem'];
    return Wrap(
      spacing: 8,
      children: [
        for (final category in categories)
          ChoiceChip(
            label: Text(
              '$category ${category == 'Semua' ? _items.length : _items.where((item) => item.category == category).length}',
            ),
            selected: _category == category,
            onSelected: (_) => setState(() => _category = category),
            selectedColor: _blue,
            labelStyle: TextStyle(
              color: _category == category ? Colors.white : _ink,
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: const Color(0xFFE8EEFF),
            side: BorderSide.none,
            showCheckmark: false,
          ),
      ],
    );
  }

  Widget _list({bool showSettings = false}) => ListView.separated(
    padding: const EdgeInsets.only(bottom: 20),
    itemCount: _visible.length + (showSettings ? 2 : 1),
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      if (index < _visible.length) {
        final item = _visible[index];
        return _notificationCard(item);
      }
      if (showSettings && index == _visible.length) return _settingsCard();
      return _archiveCard();
    },
  );

  Widget _notificationCard(_Notification item) {
    final color = switch (item.category) {
      'Perizinan' => const Color(0xFFDC2626),
      'Sistem' => const Color(0xFF065F46),
      _ => _blue,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.read ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: item.iconBackground,
            child: Icon(item.icon, color: item.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        fontSize: 14,
                      ),
                    ),
                    _badge(item.category, color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: GoogleFonts.manrope(
                    color: _muted,
                    height: 1.5,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.footer,
                        style: GoogleFonts.manrope(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (item.action != null)
                      TextButton(
                        onPressed: () {
                          setState(() => item.read = true);
                          if (item.title == 'Pengajuan Mitra Baru') {
                            _openAdmin(1);
                          } else {
                            _message(item.actionMessage);
                          }
                        },
                        child: Text(item.action!),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.time,
            style: GoogleFonts.manrope(fontSize: 11, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE4EAF6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.desktop_windows_outlined, color: _blue),
        const SizedBox(height: 10),
        Text(
          'Notifikasi desktop',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        Text(
          'Izinkan LokaTrip mengirim pembaruan ke notifikasi sistem.',
          style: GoogleFonts.manrope(fontSize: 12, height: 1.5, color: _muted),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Selalu izinkan'),
          value: _desktopAllowed,
          onChanged: _busy || !DesktopNotificationService.isSupported
              ? null
              : _setDesktopAllowed,
        ),
        if (_desktopAllowed)
          OutlinedButton.icon(
            onPressed: _busy ? null : _sendTest,
            icon: const Icon(Icons.send_outlined, size: 16),
            label: const Text('Kirim notifikasi uji'),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: GoogleFonts.manrope(color: Colors.red, fontSize: 11),
            ),
          ),
        if (_desktopAllowed)
          Text(
            'Toast mengikuti izin notifikasi di pengaturan Windows.',
            style: GoogleFonts.manrope(fontSize: 10, color: _muted),
          ),
      ],
    ),
  );

  Widget _archiveCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE3EBFF),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Color(0xFF1E3A8A),
          child: Icon(Icons.mark_email_read_outlined, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Notifikasi berumur lebih dari 30 hari dipindahkan ke arsip.',
            style: GoogleFonts.manrope(fontSize: 12, color: _muted),
          ),
        ),
      ],
    ),
  );

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: GoogleFonts.manrope(
        color: color,
        fontWeight: FontWeight.w800,
        fontSize: 10,
      ),
    ),
  );
}

class _Notification {
  final String category;
  final String title;
  final String time;
  final String body;
  final String footer;
  final String? action;
  final String actionMessage;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  bool read;

  _Notification({
    required this.category,
    required this.title,
    required this.time,
    required this.body,
    required this.footer,
    required this.actionMessage,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.read,
    this.action,
  });
}

List<_Notification> _notifications() => [
  _Notification(
    category: 'Mitra',
    title: 'Pengajuan Mitra Baru',
    time: '5 mnt lalu',
    body:
        'CV Pesona Nusantara mengajukan pendaftaran sebagai mitra pengelola wisata baru.',
    footer: 'SLA: 23 jam tersisa',
    action: 'Tinjau Pengajuan',
    actionMessage: 'Membuka pengajuan mitra.',
    icon: Icons.apartment,
    iconColor: _blue,
    iconBackground: const Color(0xFFDBEAFE),
    read: false,
  ),
  _Notification(
    category: 'Perizinan',
    title: 'Izin Akan Berakhir',
    time: '2 jam lalu',
    body:
        'Izin operasional Gunung Bromo Adventure akan berakhir dalam 14 hari kerja.',
    footer: 'Batas: 28 Okt 2026',
    action: 'Kirim Pengingat',
    actionMessage: 'Pengingat izin sedang disiapkan.',
    icon: Icons.hourglass_bottom,
    iconColor: const Color(0xFF0369A1),
    iconBackground: const Color(0xFFBAE6FD),
    read: false,
  ),
  _Notification(
    category: 'Mitra',
    title: 'Dokumen Perlu Diperiksa',
    time: 'Kemarin, 16:40',
    body:
        'Dokumen legalitas PT Jelajah Indonesia membutuhkan pemeriksaan ulang kelengkapan berkas TDUP.',
    footer: 'PIC: Maya Indrawati',
    action: 'Buka Berkas',
    actionMessage: 'Berkas mitra siap ditinjau.',
    icon: Icons.assignment_outlined,
    iconColor: _blue,
    iconBackground: const Color(0xFFDBEAFE),
    read: true,
  ),
  _Notification(
    category: 'Sistem',
    title: 'Sinkronisasi Data OSS Berhasil',
    time: '2 hari lalu',
    body:
        'Sistem otomatis memperbarui 12 status izin usaha terintegrasi dengan portal Kemeninvest/OSS Nasional.',
    footer: 'Status Sinkron: 100% Valid',
    actionMessage: 'Sinkronisasi data berhasil.',
    icon: Icons.monitor_heart_outlined,
    iconColor: const Color(0xFF065F46),
    iconBackground: const Color(0xFFA7F3D0),
    read: true,
  ),
];
