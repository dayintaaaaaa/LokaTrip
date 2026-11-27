import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_client.dart';
import '../../core/app_color.dart';
import '../../core/session_manager.dart';
import '../../widgets/bottom_navigator.dart';

class _Notif {
  final int id;
  final String judul;
  final String isi;
  final String jenis;
  final DateTime? tanggal;
  final bool dibaca;

  const _Notif({
    required this.id,
    required this.judul,
    required this.isi,
    required this.jenis,
    required this.tanggal,
    required this.dibaca,
  });

  factory _Notif.fromMap(Map<String, dynamic> row) => _Notif(
    id: (row['id_notifikasi'] as num).toInt(),
    judul: row['judul'] as String? ?? 'Notifikasi',
    isi: row['isi'] as String? ?? '',
    jenis: row['jenis'] as String? ?? '',
    tanggal: DateTime.tryParse(row['tanggal']?.toString() ?? '')?.toLocal(),
    dibaca: row['status_baca'] == true,
  );

  IconData get icon {
    final value = jenis.toLowerCase();
    if (value.contains('pesan') ||
        value.contains('transaksi') ||
        value.contains('bayar')) {
      return Icons.confirmation_number_outlined;
    }
    if (value.contains('jadwal') || value.contains('ingat')) {
      return Icons.event_available_outlined;
    }
    if (value.contains('promo')) return Icons.local_offer_outlined;
    if (value.contains('aman') || value.contains('akun')) {
      return Icons.shield_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  String get label =>
      jenis.isEmpty ? 'PEMBARUAN' : jenis.replaceAll('_', ' ').toUpperCase();
  String get waktu {
    if (tanggal == null) return '';
    final selisih = DateTime.now().difference(tanggal!);
    if (selisih.inMinutes < 1) return 'Baru saja';
    if (selisih.inHours < 1) return '${selisih.inMinutes} mnt lalu';
    if (selisih.inDays < 1) return '${selisih.inHours} jam lalu';
    if (selisih.inDays < 7) return '${selisih.inDays} hari lalu';
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${tanggal!.day} ${bulan[tanggal!.month - 1]} ${tanggal!.year}';
  }
}

class NotifikasiScreens extends StatefulWidget {
  const NotifikasiScreens({super.key});
  @override
  State<NotifikasiScreens> createState() => _NotifikasiScreensState();
}

class _NotifikasiScreensState extends State<NotifikasiScreens> {
  List<_Notif> _daftar = const [];
  bool _memuat = true;
  bool _memprosesSemua = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _memuat = true;
      _error = null;
    });
    try {
      final token = await SessionManager.currentUserToken();
      if (token == null || token.isEmpty) {
        throw StateError('Silakan masuk untuk melihat notifikasi.');
      }
      final rows = await UserApi.notifications(token);
      if (!mounted) return;
      setState(() {
        _daftar = rows.map(_Notif.fromMap).toList();
        _memuat = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _memuat = false;
      });
    }
  }

  Future<void> _tandaiDibaca(_Notif notif) async {
    if (notif.dibaca) return;
    final token = await SessionManager.currentUserToken();
    if (token == null) return;
    try {
      await UserApi.markNotificationRead(token, notif.id);
      if (!mounted) return;
      setState(() {
        _daftar = _daftar
            .map(
              (n) => n.id == notif.id
                  ? _Notif(
                      id: n.id,
                      judul: n.judul,
                      isi: n.isi,
                      jenis: n.jenis,
                      tanggal: n.tanggal,
                      dibaca: true,
                    )
                  : n,
            )
            .toList();
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifikasi belum bisa ditandai dibaca: $error'),
          ),
        );
      }
    }
  }

  Future<void> _tandaiSemuaDibaca() async {
    if (_daftar.every((n) => n.dibaca) || _memprosesSemua) return;
    setState(() => _memprosesSemua = true);
    try {
      final token = await SessionManager.currentUserToken();
      if (token == null) throw StateError('Silakan masuk kembali.');
      await UserApi.markAllNotificationsRead(token);
      if (!mounted) return;
      setState(() {
        _daftar = _daftar
            .map(
              (n) => _Notif(
                id: n.id,
                judul: n.judul,
                isi: n.isi,
                jenis: n.jenis,
                tanggal: n.tanggal,
                dibaca: true,
              ),
            )
            .toList();
        _memprosesSemua = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi sudah dibaca.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _memprosesSemua = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menandai notifikasi: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final belumDibaca = _daftar.where((n) => !n.dibaca).toList();
    final sudahDibaca = _daftar.where((n) => n.dibaca).toList();
    return Scaffold(
      backgroundColor: AppColor.ungu.withValues(alpha: 0.05),
      appBar: AppBar(
        backgroundColor: AppColor.putih,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: AppColor.hitam, size: 22),
        ),
        titleSpacing: 0,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColor.hitam,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tandai semua sudah dibaca',
            onPressed: _memprosesSemua ? null : _tandaiSemuaDibaca,
            icon: _memprosesSemua
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.done_all,
                    color: belumDibaca.isEmpty ? AppColor.abu : AppColor.ungu,
                    size: 20,
                  ),
          ),
        ],
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _pesanKosong(_error!, aksi: 'Coba lagi', onTap: _muat)
          : _daftar.isEmpty
          ? _pesanKosong('Belum ada notifikasi.')
          : RefreshIndicator(
              onRefresh: _muat,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                children: [
                  _judulBagian('Terbaru', '${belumDibaca.length} BELUM DIBACA'),
                  const SizedBox(height: 12),
                  if (belumDibaca.isEmpty)
                    _kosongBagian('Tidak ada notifikasi baru.')
                  else
                    ...belumDibaca.map(
                      (n) =>
                          _NotifCard(notif: n, onTap: () => _tandaiDibaca(n)),
                    ),
                  const SizedBox(height: 10),
                  _judulBagian('Terdahulu', 'Sudah dibaca'),
                  const SizedBox(height: 12),
                  if (sudahDibaca.isEmpty)
                    _kosongBagian('Notifikasi yang dibaca akan muncul di sini.')
                  else
                    ...sudahDibaca.map(
                      (n) => _NotifCard(notif: n, onTap: () {}),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavigator(currentIndex: -1),
    );
  }

  Widget _judulBagian(String judul, String sisi) => Row(
    children: [
      Text(
        judul,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColor.hitam,
        ),
      ),
      const Spacer(),
      Text(
        sisi,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColor.ungu,
        ),
      ),
    ],
  );

  Widget _kosongBagian(String pesan) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Text(
      pesan,
      style: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
    ),
  );

  Widget _pesanKosong(String pesan, {String? aksi, VoidCallback? onTap}) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(pesan, textAlign: TextAlign.center),
              if (aksi != null) TextButton(onPressed: onTap, child: Text(aksi)),
            ],
          ),
        ),
      );
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final warna = notif.dibaca
        ? AppColor.hitam.withValues(alpha: 0.65)
        : AppColor.ungu;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColor.putih,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.hitam.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.icon, size: 20, color: warna),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: warna,
                          ),
                        ),
                      ),
                      Text(
                        notif.waktu,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColor.abu,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        notif.dibaca ? Icons.done_all_rounded : Icons.circle,
                        size: notif.dibaca ? 15 : 7,
                        color: notif.dibaca ? AppColor.biru : AppColor.ungu,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notif.judul,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.isi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColor.hitam.withValues(alpha: 0.65),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
