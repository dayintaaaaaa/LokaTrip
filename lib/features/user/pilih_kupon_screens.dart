import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format_rupiah.dart';
import '../../models/kupon_dummy.dart';

// hasil dari halaman ini (kupon null = kupon dihapus)
class KuponHasil {
  final Kupon? kupon;
  const KuponHasil(this.kupon);
}

class PilihKuponScreens extends StatefulWidget {
  final int subtotal;
  final Kupon? terpilih;

  const PilihKuponScreens({
    super.key,
    required this.subtotal,
    this.terpilih,
  });

  @override
  State<PilihKuponScreens> createState() => _PilihKuponScreensState();
}

class _PilihKuponScreensState extends State<PilihKuponScreens> {
  final _kodeC = TextEditingController();
  Kupon? _dipilih;
  String? _error;

  // kupon tanpa tampilan khusus tidak ditampilkan di daftar
  List<Kupon> get _daftar =>
      KuponDummy.daftar
          .where((k) => k.syarat != 'Berlaku untuk semua wisata')
          .toList();

  @override
  void initState() {
    super.initState();
    _dipilih = widget.terpilih;
  }

  @override
  void dispose() {
    _kodeC.dispose();
    super.dispose();
  }

  void _terapkanKode() {
    final kode = _kodeC.text.trim();

    if (kode.isEmpty) {
      setState(() => _error = 'Masukkan kode kupon dulu');
      return;
    }

    final k = KuponDummy.cari(kode);

    setState(() {
      if (k == null) {
        _error = 'Kode kupon tidak ditemukan';
      } else if (!k.layak(widget.subtotal)) {
        _error =
            'Minimal transaksi ${formatRupiah(k.minTransaksi)}';
      } else {
        _dipilih = k;
        _error = null;
        _kodeC.clear();
      }
    });
  }

  void _gunakan(Kupon k) {
    if (!k.layak(widget.subtotal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimal transaksi ${formatRupiah(k.minTransaksi)}',
            style: GoogleFonts.manrope(),
          ),
        ),
      );
      return;
    }

    setState(() {
      _dipilih = k;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hemat = _dipilih?.hitung(widget.subtotal) ?? 0;

    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                _inputKode(),
                const SizedBox(height: 14),
                ..._daftar.map(_kartu),
              ],
            ),
          ),
          _bawah(hemat),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: AppColor.latar,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promo & Kupon Spesial',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColor.hitam,
                      ),
                    ),
                    Text(
                      'Pilih voucher hemat liburan',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: AppColor.abu,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.help_outline,
                color: AppColor.abu,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputKode() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _dekor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PUNYA KODE PROMO? MASUKKAN DI SINI',
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColor.hitam.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColor.latar,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 16,
                        color: AppColor.abu,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _kodeC,
                          textCapitalization:
                              TextCapitalization.characters,
                          onSubmitted: (_) => _terapkanKode(),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColor.hitam,
                          ),
                          decoration: InputDecoration(
                            hintText: 'CONTOH: LIBURANSERU',
                            hintStyle: GoogleFonts.manrope(
                              fontSize: 11,
                              color: AppColor.abu,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _terapkanKode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.ungu,
                  foregroundColor: AppColor.putih,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Terapkan',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(
              _error!,
              style: GoogleFonts.manrope(
                fontSize: 10,
                color: const Color(0xFFE53935),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kartu(Kupon k) {
    final layak = k.layak(widget.subtotal);
    final pilih = _dipilih?.kode == k.kode;

    return Opacity(
      opacity: layak ? 1 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.putih,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: pilih
                ? AppColor.ungu
                : AppColor.abu.withValues(alpha: 0.15),
            width: pilih ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColor.biru.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    k.icon,
                    size: 20,
                    color: AppColor.ungu,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              k.kode,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColor.ungu,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (pilih)
                            _chip(
                              '✓ TERPASANG',
                              AppColor.ungu,
                              AppColor.putih,
                            )
                          else if (k.badge != null)
                            _chip(
                              k.badge!,
                              k.badgeWarna.withValues(alpha: 0.2),
                              k.badgeWarna,
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          text: k.judulTampil,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                          children: [
                            if (k.catatan.isNotEmpty)
                              TextSpan(
                                text: '  ${k.catatan}',
                                style: GoogleFonts.manrope(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.abu,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (pilih)
                  InkWell(
                    onTap: () => setState(() => _dipilih = null),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColor.kuning,
                        ),
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _gunakan(k),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColor.ungu.withValues(alpha: 0.1),
                      foregroundColor: AppColor.ungu,
                      elevation: 0,
                      minimumSize: Size.zero,
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Gunakan',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: AppColor.abu.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  k.syaratIcon,
                  size: 13,
                  color: AppColor.abu,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    layak
                        ? k.syarat
                        : 'Min. transaksi ${formatRupiah(k.minTransaksi)}',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: AppColor.hitam,
                    ),
                  ),
                ),
                if (pilih)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: k.kode),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Kode ${k.kode} disalin',
                            style: GoogleFonts.manrope(),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'Salin',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            color: AppColor.abu,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.copy,
                          size: 11,
                          color: AppColor.abu,
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    k.aksi,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: k.aksi == 'Flash Sale'
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: k.aksi == 'Flash Sale'
                          ? AppColor.kuning
                          : AppColor.abu,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String teks, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  Widget _bawah(int hemat) {
    final jumlah = _dipilih == null ? 0 : 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColor.biru.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColor.ungu,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hemat terpasang:',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: AppColor.hitam,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatRupiah(hemat),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColor.ungu,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  KuponHasil(_dipilih),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.ungu,
                  foregroundColor: AppColor.putih,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Terapkan Promo ($jumlah Terpilih)',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _dekor() {
    return BoxDecoration(
      color: AppColor.putih,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: AppColor.abu.withValues(alpha: 0.15),
      ),
    );
  }
}