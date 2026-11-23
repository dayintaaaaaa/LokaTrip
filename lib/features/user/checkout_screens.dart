import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_color.dart';
import '../../core/format_rupiah.dart';
import '../../models/data_checkout.dart';
import '../../models/data_pemesanan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import 'checkout_widgets/banner_waktu.dart';
import 'checkout_widgets/form_pemesanan.dart';
import 'checkout_widgets/rincian_pembayaran.dart';
import 'checkout_widgets/ringkasan_pesanan.dart';
import 'checkout_widgets/stepper_checkout.dart';
import 'metode_pembayaran_screens.dart';

// Langkah 1 checkout: isi data pemesan.
// Pesanan di database baru dibuat di langkah berikutnya.
class CheckoutScreens extends StatefulWidget {
  final DataPemesanan pesanan;

  const CheckoutScreens({super.key, required this.pesanan});

  @override
  State<CheckoutScreens> createState() => _CheckoutScreensState();
}

class _CheckoutScreensState extends State<CheckoutScreens> {
  static const _latar = Color(0xFFF5F6FA);
  static const _batasDetik = 15 * 60;

  final _formKey = GlobalKey<FormState>();
  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _teleponC = TextEditingController();

  final _namaF = FocusNode();
  final _emailF = FocusNode();
  final _teleponF = FocusNode();

  final _sisaDetik = ValueNotifier<int>(_batasDetik);
  Timer? _timer;

  bool _pakaiProfil = false;
  Map<String, dynamic>? _profil;

  RincianHarga get _rincian =>
      RincianHarga(pesanan: widget.pesanan);

  @override
  void initState() {
    super.initState();
    _muatProfil();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_sisaDetik.value <= 1) {
        t.cancel();
        _sisaDetik.value = 0;
        _waktuHabis();
      } else {
        _sisaDetik.value--;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sisaDetik.dispose();
    _namaC.dispose();
    _emailC.dispose();
    _teleponC.dispose();
    _namaF.dispose();
    _emailF.dispose();
    _teleponF.dispose();
    super.dispose();
  }

  Future<void> _waktuHabis() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Waktu pemesanan habis'),
        content: const Text(
          'Pesananmu belum diselesaikan dalam 15 menit. '
          'Silakan atur jadwal lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );

    if (mounted) Navigator.pop(context);
  }

  // Ambil data akun yang sedang login (nama, email, telepon).
  Future<void> _muatProfil() async {
    try {
      final p = await ProfileService().getProfile();
      if (!mounted) return;
      setState(() => _profil = p);
    } catch (e) {
      debugPrint('Gagal memuat profil: $e');
    }
  }

  // Switch "Gunakan profil akun": isi otomatis, atau kosongkan lagi.
  void _gantiProfil(bool nyala) {
    final profil = _profil;

    if (nyala && profil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data profil belum tersedia, isi data pemesan secara manual',
            style: GoogleFonts.manrope(),
          ),
        ),
      );
      return;
    }

    setState(() {
      _pakaiProfil = nyala;

      if (nyala) {
        _namaC.text = (profil!['nama_lengkap_user'] ?? '') as String;

        // Email ada di akun login (auth), bukan di tabel users.
        _emailC.text =
            Supabase.instance.client.auth.currentUser?.email ?? '';

        // Di database +62812..., di form ditampilkan 0812...
        _teleponC.text = ProfileService.keFormatLokal(
          (profil['no_telephone'] ?? '') as String,
        );
      } else {
        _namaC.clear();
        _emailC.clear();
        _teleponC.clear();
      }
    });
  }

  void _lanjutBayar() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Fokus ke field pertama yang bermasalah.
      if (validasiNama(_namaC.text) != null) {
        _namaF.requestFocus();
      } else if (validasiEmail(_emailC.text) != null) {
        _emailF.requestFocus();
      } else {
        _teleponF.requestFocus();
      }
      return;
    }

    final data = DataCheckout(
      pesanan: widget.pesanan,
      nama: _namaC.text.trim(),
      email: _emailC.text.trim(),
      telepon: _teleponC.text.trim(),
      rincian: _rincian,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MetodePembayaranScreens(data: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _rincian;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _latar,
        body: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  BannerWaktu(sisaDetik: _sisaDetik),
                  const SizedBox(height: 14),
                  RingkasanPesanan(
                    pesanan: widget.pesanan,
                    onUbah: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 14),
                  FormPemesan(
                    formKey: _formKey,
                    namaC: _namaC,
                    emailC: _emailC,
                    teleponC: _teleponC,
                    namaF: _namaF,
                    emailF: _emailF,
                    teleponF: _teleponF,
                    pakaiProfil: _pakaiProfil,
                    onPakaiProfil: _gantiProfil,
                    onBerubah: () => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  RincianPembayaran(rincian: r),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _barBayar(r.total),
      ),
    );
  }

  // Header "Checkout Flow" + penanda langkah.
  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.putih,
        border: Border(
          bottom: BorderSide(
            color: AppColor.abu.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColor.hitam,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Checkout Flow',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: StepperCheckout(aktif: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barBayar(int total) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.putih,
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Tagihan',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: AppColor.hitam.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    formatRupiah(total),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.ungu,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _lanjutBayar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.ungu,
                    foregroundColor: AppColor.putih,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline, size: 17),
                      const SizedBox(width: 8),
                      Text(
                        'Lanjut Bayar',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}