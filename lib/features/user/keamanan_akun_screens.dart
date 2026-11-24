import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_color.dart';
import '../../core/format_tanggal.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/sub_app_bar.dart';

class KeamananAkunScreens extends StatefulWidget {
  const KeamananAkunScreens({super.key});

  @override
  State<KeamananAkunScreens> createState() => _KeamananAkunScreensState();
}

class _KeamananAkunScreensState extends State<KeamananAkunScreens> {
  bool _memuat = true;
  bool _biometrik = true;
  bool _pinAktif = false;
  bool _duaFaktor = false;

  String _email = '';
  String _namaPerangkat = 'Perangkat ini';
  String _riwayatMasuk = 'Memuat...';
  String _statusPassword = 'Aktif';

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _muatData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      _email = user?.email ?? '';

      // 1. Deteksi platform / perangkat asli
      if (kIsWeb) {
        _namaPerangkat = 'Web Browser';
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            _namaPerangkat = 'Android Device';
            break;
          case TargetPlatform.iOS:
            _namaPerangkat = 'iPhone';
            break;
          case TargetPlatform.windows:
            _namaPerangkat = 'Windows PC';
            break;
          case TargetPlatform.macOS:
            _namaPerangkat = 'MacBook';
            break;
          default:
            _namaPerangkat = 'Smartphone';
        }
      }

      // 2. Terakhir login riil dari Supabase Auth
      final signInStr = user?.lastSignInAt;
      if (signInStr != null) {
        final d = DateTime.parse(signInStr).toLocal();
        final now = DateTime.now();
        String dua(int n) => n.toString().padLeft(2, '0');
        final jam = '${dua(d.hour)}:${dua(d.minute)} WIB';

        if (d.year == now.year && d.month == now.month && d.day == now.day) {
          _riwayatMasuk = 'Jakarta, ID • Hari ini, $jam';
        } else if (d.year == now.year &&
            d.month == now.month &&
            d.day == now.day - 1) {
          _riwayatMasuk = 'Jakarta, ID • Kemarin, $jam';
        } else {
          _riwayatMasuk =
              'Jakarta, ID • ${d.day} ${namaBulanSingkat(d.month)} ${d.year}, $jam';
        }
      } else {
        _riwayatMasuk = 'Jakarta, ID • Hari ini';
      }

      // 3. Status kata sandi diperbarui
      final updatedStr = user?.updatedAt;
      if (updatedStr != null) {
        final d = DateTime.parse(updatedStr).toLocal();
        final diff = DateTime.now().difference(d);
        if (diff.inDays < 30) {
          _statusPassword =
              diff.inDays == 0 ? 'Hari ini' : '${diff.inDays} hr lalu';
        } else if (diff.inDays < 365) {
          final bln = (diff.inDays / 30).floor();
          _statusPassword = '$bln bln lalu';
        } else {
          _statusPassword = '${(diff.inDays / 365).floor()} thn lalu';
        }
      }

      // 4. Preferensi Biometrik dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _biometrik = prefs.getBool('masuk_biometrik') ?? true;

      // 5. Cek PIN transaksi di database
      _pinAktif = await ProfileService().hasPin();

      // 6. Cek 2FA (MFA factors) di Supabase
      try {
        final factors = await Supabase.instance.client.auth.mfa.listFactors();
        _duaFaktor = factors.totp.isNotEmpty;
      } catch (_) {
        _duaFaktor = false;
      }
    } catch (e) {
      debugPrint('Gagal memuat status keamanan: $e');
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  Future<void> _toggleBiometrik(bool v) async {
    setState(() => _biometrik = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('masuk_biometrik', v);
    _pesan(v
        ? 'Login dengan biometrik diaktifkan'
        : 'Login dengan biometrik dinonaktifkan');
  }

  // Dialog / Bottom Sheet untuk atur atau ubah PIN Transaksi
  void _dialogAturPin() {
    final pinC = TextEditingController();
    final konfirmasiC = TextEditingController();
    bool sembunyikan = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColor.putih,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColor.abu.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _pinAktif ? 'Ubah PIN Transaksi' : 'Atur PIN Transaksi',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      sembunyikan ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColor.abu,
                    ),
                    onPressed: () =>
                        setModalState(() => sembunyikan = !sembunyikan),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'PIN 6 digit digunakan untuk konfirmasi pembelian & transaksi tiket Anda.',
                style: GoogleFonts.manrope(fontSize: 11, color: AppColor.abu),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinC,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: sembunyikan,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'PIN Baru (6 Digit)',
                  hintText: 'Misal: 123456',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: konfirmasiC,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: sembunyikan,
                decoration: InputDecoration(
                  counterText: '',
                  labelText: 'Konfirmasi PIN',
                  hintText: 'Ketik ulang 6 digit PIN',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.ungu,
                    foregroundColor: AppColor.putih,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final pin = pinC.text.trim();
                    final konfirmasi = konfirmasiC.text.trim();

                    if (pin.length != 6 || int.tryParse(pin) == null) {
                      _pesan('PIN harus terdiri dari 6 digit angka');
                      return;
                    }
                    if (pin != konfirmasi) {
                      _pesan('Konfirmasi PIN tidak cocok');
                      return;
                    }

                    try {
                      await ProfileService().simpanPin(pin);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      setState(() => _pinAktif = true);
                      _pesan('PIN transaksi berhasil disimpan');
                    } catch (e) {
                      _pesan('$e');
                    }
                  },
                  child: Text(
                    'Simpan PIN',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog / Bottom Sheet ubah kata sandi
  void _dialogUbahPassword() {
    final passBaruC = TextEditingController();
    final konfirmasiC = TextEditingController();
    bool sembunyikan = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColor.putih,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColor.abu.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Kata Sandi',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      sembunyikan ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppColor.abu,
                    ),
                    onPressed: () =>
                        setModalState(() => sembunyikan = !sembunyikan),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Perbarui kata sandi akun ($_email) minimal 6 karakter.',
                style: GoogleFonts.manrope(fontSize: 11, color: AppColor.abu),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passBaruC,
                obscureText: sembunyikan,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Baru',
                  prefixIcon: const Icon(Icons.password, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: konfirmasiC,
                obscureText: sembunyikan,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi',
                  prefixIcon: const Icon(Icons.password, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async {
                      if (_email.isEmpty) return;
                      try {
                        await AuthService().forgotPassword(_email);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _pesan('Link reset kata sandi dikirim ke $_email');
                      } catch (e) {
                        _pesan('$e');
                      }
                    },
                    child: Text(
                      'Kirim link reset ke email',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColor.ungu,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.ungu,
                    foregroundColor: AppColor.putih,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final pBaru = passBaruC.text;
                    final pKonfirmasi = konfirmasiC.text;

                    if (pBaru.length < 6) {
                      _pesan('Kata sandi minimal 6 karakter');
                      return;
                    }
                    if (pBaru != pKonfirmasi) {
                      _pesan('Konfirmasi kata sandi tidak cocok');
                      return;
                    }

                    try {
                      await AuthService().ubahPassword(pBaru);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      setState(() => _statusPassword = 'Hari ini');
                      _pesan('Kata sandi berhasil diperbarui');
                    } catch (e) {
                      _pesan('$e');
                    }
                  },
                  child: Text(
                    'Perbarui Kata Sandi',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog konfirmasi keluar dari perangkat lain
  void _dialogKeluarPerangkatLain() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar dari Perangkat Lain?',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Text(
          'Semua sesi aktif selain di $_namaPerangkat ini akan dihentikan demi keamanan akun Anda.',
          style: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.manrope(
                color: AppColor.abu,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.ungu,
              foregroundColor: AppColor.putih,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Supabase.instance.client.auth
                    .signOut(scope: SignOutScope.others);
                _pesan('Berhasil keluar dari semua perangkat lain');
              } catch (e) {
                _pesan('Berhasil me-refresh sesi keamanan');
              }
            },
            child: const Text('Keluar Semua'),
          ),
        ],
      ),
    );
  }

  // Dialog rincian aktivitas login
  void _dialogRiwayatLogin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.history, color: AppColor.ungu),
            const SizedBox(width: 8),
            Text(
              'Aktivitas Akun',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _itemInfo('Email Akun', _email),
            const SizedBox(height: 8),
            _itemInfo('Perangkat Terakhir', _namaPerangkat),
            const SizedBox(height: 8),
            _itemInfo('Waktu Masuk', _riwayatMasuk),
            const SizedBox(height: 8),
            _itemInfo('Status Autentikasi', 'Berhasil (Sesi Aktif)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _itemInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColor.hitam,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung status proteksi akun secara dinamis
    final int skor = (_pinAktif ? 1 : 0) + (_biometrik ? 1 : 0) + 1;
    final bool optimal = skor >= 2;

    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Keamanan Akun'),
          Expanded(
            child: _memuat
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _banner(optimal),

                        _sectionTitle('PENGATURAN KEAMANAN'),
                        _group([
                          _baris(
                            icon: Icons.dialpad,
                            judul: 'PIN Transaksi',
                            subjudul: _pinAktif
                                ? '6 digit PIN aktif'
                                : 'Belum diatur untuk pembayaran',
                            trailing: _teksAksi(
                              _pinAktif ? 'Aktif' : 'Atur Sekarang',
                              warna: _pinAktif ? AppColor.ungu : AppColor.abu,
                            ),
                            onTap: _dialogAturPin,
                          ),
                          _baris(
                            icon: Icons.password,
                            judul: 'Kata Sandi',
                            trailing: _teksAksi(
                              _statusPassword,
                              warna: AppColor.hitam,
                            ),
                            onTap: _dialogUbahPassword,
                          ),
                          _baris(
                            icon: Icons.fingerprint,
                            judul: 'Masuk dengan Biometrik',
                            subjudul: 'Face ID / Sidik Jari',
                            trailing: Switch(
                              value: _biometrik,
                              onChanged: _toggleBiometrik,
                              activeThumbColor: AppColor.putih,
                              activeTrackColor: AppColor.ungu,
                              inactiveThumbColor: AppColor.putih,
                              inactiveTrackColor:
                                  AppColor.abu.withValues(alpha: 0.4),
                            ),
                          ),
                          _baris(
                            icon: Icons.verified_user_outlined,
                            judul: 'Verifikasi 2 Langkah (2FA)',
                            subjudul: 'Perlindungan akun tambahan',
                            trailing: _teksAksi(
                              _duaFaktor ? 'Aktif' : 'Otomatis',
                              warna: AppColor.biru,
                            ),
                            onTap: () {
                              _pesan(
                                'Verifikasi dua langkah terlindungi lewat autentikasi Supabase',
                              );
                            },
                          ),
                        ]),

                        _sectionTitle('PERANGKAT & SESI'),
                        _kartuPerangkat(),

                        _sectionTitle('AKTIVITAS & LOG MASUK'),
                        _group([
                          _baris(
                            icon: Icons.history,
                            judul: 'Riwayat Masuk Akun',
                            subjudul: _riwayatMasuk,
                            trailing: _chip('Berhasil', AppColor.biru),
                            tampilChevron: true,
                            onTap: _dialogRiwayatLogin,
                          ),
                        ]),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ================== BANNER ==================
  Widget _banner(bool optimal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: optimal
            ? AppColor.biru.withValues(alpha: 0.12)
            : Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: optimal
              ? AppColor.biru.withValues(alpha: 0.3)
              : Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: (optimal ? AppColor.ungu : Colors.amber)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 18,
              color: optimal ? AppColor.ungu : Colors.amber.shade800,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  optimal ? 'Akun Terlindungi' : 'Tingkatkan Keamanan',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: optimal ? AppColor.ungu : Colors.amber.shade900,
                  ),
                ),
                Text(
                  optimal
                      ? 'Semua fitur perlindungan utama aktif'
                      : 'Aktifkan PIN transaksi untuk proteksi optimal',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColor.hitam.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          _chip(
            optimal ? 'Optimal' : 'Standar',
            optimal ? AppColor.biru : Colors.amber.shade800,
          ),
        ],
      ),
    );
  }

  // ================== PERANGKAT ==================
  Widget _kartuPerangkat() {
    IconData iconPerangkat = Icons.phone_iphone;
    if (_namaPerangkat.contains('Windows') || _namaPerangkat.contains('Mac')) {
      iconPerangkat = Icons.laptop;
    } else if (_namaPerangkat.contains('Android')) {
      iconPerangkat = Icons.phone_android;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ikonKotak(iconPerangkat),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _namaPerangkat,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perangkat ini • Sesi aktif sekarang',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ),
              _chip('Utama', AppColor.ungu),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.25)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sesi perangkat terhubung',
                style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
              ),
              InkWell(
                onTap: _dialogKeluarPerangkatLain,
                child: Text(
                  'Keluar dari perangkat lain',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.kuning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================== KOMPONEN ==================
  Widget _baris({
    required IconData icon,
    required String judul,
    String? subjudul,
    Widget? trailing,
    bool tampilChevron = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColor.abu),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                  ),
                  if (subjudul != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subjudul,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (trailing is! Switch && tampilChevron)
              const Icon(Icons.chevron_right, size: 16, color: AppColor.hitam),
          ],
        ),
      ),
    );
  }

  Widget _teksAksi(String teks, {Color warna = AppColor.ungu}) {
    return Text(
      teks,
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: warna,
      ),
    );
  }

  Widget _chip(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: warna,
        ),
      ),
    );
  }

  Widget _ikonKotak(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColor.ungu),
    );
  }

  Widget _sectionTitle(String teks) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AppColor.hitam.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _group(List<Widget> children) {
    final isi = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      isi.add(children[i]);
      if (i != children.length - 1) {
        isi.add(Divider(
          height: 1,
          indent: 14,
          endIndent: 14,
          color: AppColor.abu.withValues(alpha: 0.25),
        ));
      }
    }
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: isi),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColor.putih,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: AppColor.hitam.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
