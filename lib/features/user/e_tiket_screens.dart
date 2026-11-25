import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_color.dart';
import '../../core/format_waktu.dart';
import '../../models/data_checkout.dart';
import '../../widgets/gambar_wisata.dart';
import '../../widgets/qr_palsu.dart';

class ETiketScreens extends StatelessWidget {
  final DataCheckout data;
  final String kode;

  const ETiketScreens({super.key, required this.data, required this.kode});

  // TODO: kode scan sebaiknya dibuat backend
  String get _kodeScan {
    final angka = (kode.hashCode.abs() % 1000000000000).toString().padLeft(
      12,
      '0',
    );
    return '${angka.substring(0, 4)}-${angka.substring(4, 8)}-${angka.substring(8)}';
  }

  void _info(BuildContext context, String teks) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(teks, style: GoogleFonts.manrope())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColor.ungu),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'E-Tiket Wisata',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                        Text(
                          'LOKATRIP CONCIERGE',
                          style: GoogleFonts.manrope(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColor.ungu,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Bagikan tiket',
                    onPressed: () => _bagikanTiket(context),
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 20,
                      color: AppColor.hitam,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: _kartu(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bagikanTiket(BuildContext context) async {
    final pesanan = data.pesanan;
    final lokasi = pesanan.detail.lokasi.trim();
    final tautanPeta = lokasi.isEmpty
        ? null
        : Uri.https('www.google.com', '/maps/search/', {
            'api': '1',
            'query': lokasi,
          });
    final teks = [
      'E-Tiket LokaTrip: ${pesanan.detail.judul}',
      'Tanggal kunjungan: ${tglPanjang(pesanan.tanggal)}',
      if (lokasi.isNotEmpty) 'Lokasi: $lokasi',
      'Nama pemesan: ${data.nama}',
      'Pengunjung: ${pesanan.teksTamu}',
      'Kode booking: $kode',
      'Kode scan: $_kodeScan',
      if (tautanPeta != null) 'Lihat lokasi: $tautanPeta',
    ].join('\n');

    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'E-Tiket ${pesanan.detail.judul}',
          text: teks,
          mailToFallbackEnabled: false,
        ),
      );
    } catch (_) {
      try {
        await Clipboard.setData(ClipboardData(text: teks));
        if (!context.mounted) return;
        _info(
          context,
          'Detail tiket disalin. Tempelkan di aplikasi untuk membagikannya.',
        );
      } catch (error) {
        if (!context.mounted) return;
        _info(context, 'Tiket belum bisa dibagikan: $error');
      }
    }
  }

  Widget _kartu(BuildContext context) {
    final p = data.pesanan;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColor.ungu, AppColor.biru]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _chip(
                      'TIKET AKTIF',
                      AppColor.kuning.withValues(alpha: 0.2),
                      AppColor.kuning,
                      dot: true,
                    ),
                    const SizedBox(width: 6),
                    _chip(
                      'VIP PASS',
                      AppColor.biru.withValues(alpha: 0.2),
                      AppColor.ungu,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: kode));
                        _info(context, 'Kode tiket disalin');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.latar,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '#$kode',
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColor.ungu,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.copy,
                              size: 10,
                              color: AppColor.ungu,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: GambarWisata(path: p.detail.gambar),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: AppColor.ungu,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  p.detail.lokasi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.ungu,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            p.detail.judul,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColor.hitam,
                            ),
                          ),
                          Text(
                            '${p.grup.nama} • ${p.paket.namaPendek}',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              color: AppColor.abu,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.25)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _kolom(
                        'TANGGAL KUNJUNGAN',
                        Icons.calendar_today_outlined,
                        tglPanjang(p.tanggal),
                        p.paket.namaPendek,
                      ),
                    ),
                    Expanded(
                      child: _kolom(
                        'JUMLAH PENGUNJUNG',
                        Icons.people_outline,
                        p.teksTamu,
                        'a.n. ${data.nama}',
                        warnaSub: AppColor.ungu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColor.abu.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.meeting_room_outlined,
                        size: 13,
                        color: AppColor.abu,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'LOKASI: ',
                        style: GoogleFonts.manrope(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColor.abu,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          p.detail.lokasi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                      ),
                      Text(
                        'Jalur Cepat ⚡',
                        style: GoogleFonts.manrope(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // pemisah sobekan tiket
          Row(
            children: [
              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColor.latar,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (_, c) {
                    final n = (c.maxWidth / 8).floor();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        n,
                        (_) => Container(
                          width: 4,
                          height: 1.5,
                          color: AppColor.abu.withValues(alpha: 0.4),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 10,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColor.latar,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          // QR
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.putih,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.hitam.withValues(alpha: 0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // TODO: ganti dengan QR asli berisi token tiket dari backend
                      QrPalsu(seed: kode, ukuran: 150, warna: AppColor.ungu),
                      const SizedBox(height: 8),
                      Text(
                        'KODE SCAN: $_kodeScan',
                        style: GoogleFonts.manrope(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColor.abu,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tunjukkan QR code ini ke petugas di gerbang masuk wisata',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColor.hitam.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.biru.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wb_sunny_outlined,
                        size: 12,
                        color: AppColor.kuning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Atur kecerahan layar maksimal saat memindai',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColor.ungu,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String teks, Color bg, Color fg, {bool dot = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Icon(Icons.circle, size: 6, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            teks,
            style: GoogleFonts.manrope(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kolom(
    String label,
    IconData icon,
    String nilai,
    String sub, {
    Color warnaSub = AppColor.abu,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: AppColor.abu,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 12, color: AppColor.ungu),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                nilai,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColor.hitam,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 1),
          child: Text(
            sub,
            style: GoogleFonts.manrope(fontSize: 9, color: warnaSub),
          ),
        ),
      ],
    );
  }
}
