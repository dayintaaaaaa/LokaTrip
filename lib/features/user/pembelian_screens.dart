import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/promo_data.dart';
import '../../widgets/sub_app_bar.dart';
import '../../widgets/gambar_placeholder.dart';
import 'pesanan_screens.dart';

class PembelianScreens extends StatefulWidget {
  final PromoItem item;

  const PembelianScreens({super.key, required this.item});

  @override
  State<PembelianScreens> createState() => _PembelianScreensState();
}

class _PembelianScreensState extends State<PembelianScreens> {
  late DateTime _tanggal;
  int _jumlah = 1;
  int _metode = 0;
  bool _loading = false;

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const _daftarMetode = [
    ('Virtual Account', 'BCA, Mandiri, BNI, BRI', Icons.account_balance_outlined),
    ('E-Wallet', 'GoPay, OVO, DANA, ShopeePay', Icons.account_balance_wallet_outlined),
    ('QRIS', 'Scan dari aplikasi apa pun', Icons.qr_code_2),
    ('Kartu Kredit / Debit', 'Visa, Mastercard', Icons.credit_card),
  ];

  PromoItem get _p => widget.item;

  // flash sale dibatasi sesuai sisa tiket
  int get _maks => _p.tipe == PromoTipe.flash ? _p.sisaTiket : 10;
  int get _total => _p.harga * _jumlah;
  int get _hemat => (_p.hargaCoret - _p.harga) * _jumlah;

  @override
  void initState() {
    super.initState();
    _tanggal = DateTime.now().add(const Duration(days: 1));
  }

  String get _teksTanggal =>
      '${_tanggal.day} ${_bulan[_tanggal.month - 1]} ${_tanggal.year}';

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (hasil != null) setState(() => _tanggal = hasil);
  }

  Future<void> _bayar() async {
    setState(() => _loading = true);

    // TODO: panggil API backend untuk membuat pesanan & pembayaran.
    // Saat ini hanya simulasi, belum ada transaksi sungguhan.
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _loading = false);

    final kode = 'LKT-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColor.putih,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColor.biru.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 32, color: AppColor.ungu),
            ),
            const SizedBox(height: 14),
            Text(
              'Pesanan Berhasil!',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColor.hitam,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$_jumlah ${_p.satuanJumlah} • ${_p.judul}',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 11, color: AppColor.abu),
            ),
            const SizedBox(height: 10),
            Text(
              'Kode pesanan: $kode',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColor.ungu,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // tutup dialog
              Navigator.pop(context); // kembali ke Promo
            },
            child: Text(
              'Kembali ke Promo',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColor.abu,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PesananScreens()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.ungu,
              foregroundColor: AppColor.putih,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Lihat Pesanan',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Pemesanan'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ringkasan(),
                  const SizedBox(height: 14),

                  _judul('Tanggal Kunjungan'),
                  InkWell(
                    onTap: _pilihTanggal,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: _kartu(),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColor.ungu),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _teksTanggal,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColor.hitam,
                              ),
                            ),
                          ),
                          const Icon(Icons.edit_calendar_outlined,
                              size: 18, color: AppColor.abu),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _judul('Jumlah ${_p.satuanJumlah}'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _kartu(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${rp(_p.harga)} ${_p.satuan}',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.hitam,
                                ),
                              ),
                              if (_p.tipe == PromoTipe.flash)
                                Text(
                                  'Maks. $_maks (sisa tiket flash sale)',
                                  style: GoogleFonts.manrope(
                                    fontSize: 9,
                                    color: AppColor.kuning,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _tombolJumlah(
                          Icons.remove,
                          _jumlah > 1 ? () => setState(() => _jumlah--) : null,
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '$_jumlah',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColor.hitam,
                            ),
                          ),
                        ),
                        _tombolJumlah(
                          Icons.add,
                          _jumlah < _maks ? () => setState(() => _jumlah++) : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _judul('Metode Pembayaran'),
                  Container(
                    decoration: _kartu(),
                    child: Column(
                      children: List.generate(_daftarMetode.length, (i) {
                        final (nama, sub, icon) = _daftarMetode[i];
                        final aktif = _metode == i;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () => setState(() => _metode = i),
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColor.ungu.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(icon,
                                          size: 16, color: AppColor.ungu),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nama,
                                            style: GoogleFonts.manrope(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.hitam,
                                            ),
                                          ),
                                          Text(
                                            sub,
                                            style: GoogleFonts.manrope(
                                              fontSize: 9,
                                              color: AppColor.abu,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      aktif
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      size: 18,
                                      color:
                                          aktif ? AppColor.ungu : AppColor.abu,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (i != _daftarMetode.length - 1)
                              Divider(
                                height: 1,
                                indent: 14,
                                endIndent: 14,
                                color: AppColor.abu.withValues(alpha: 0.25),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _judul('Rincian Pembayaran'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _kartu(),
                    child: Column(
                      children: [
                        _barisRincian(
                          '${rp(_p.hargaCoret)} x $_jumlah',
                          rp(_p.hargaCoret * _jumlah),
                        ),
                        const SizedBox(height: 8),
                        _barisRincian(
                          'Diskon promo',
                          '- ${rp(_hemat)}',
                          warna: AppColor.ungu,
                        ),
                        const SizedBox(height: 10),
                        Divider(
                            height: 1,
                            color: AppColor.abu.withValues(alpha: 0.25)),
                        const SizedBox(height: 10),
                        _barisRincian(
                          'Total Pembayaran',
                          rp(_total),
                          tebal: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== bar bawah =====
          Container(
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.manrope(
                              fontSize: 10, color: AppColor.abu),
                        ),
                        Text(
                          rp(_total),
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColor.ungu,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _bayar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.ungu,
                      foregroundColor: AppColor.putih,
                      disabledBackgroundColor:
                          AppColor.ungu.withValues(alpha: 0.5),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.putih,
                            ),
                          )
                        : Text(
                            'Bayar Sekarang',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
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

  // ================== KOMPONEN ==================
  Widget _ringkasan() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _kartu(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: GambarPlaceholder(
                warna: _p.warna,
                tinggi: 72,
                lebar: 72,
                iconSize: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _p.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColor.ungu),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        _p.lokasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                            fontSize: 10, color: AppColor.abu),
                      ),
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

  Widget _tombolJumlah(IconData icon, VoidCallback? onTap) {
    final aktif = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: aktif
              ? AppColor.ungu.withValues(alpha: 0.1)
              : AppColor.abu.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 16, color: aktif ? AppColor.ungu : AppColor.abu),
      ),
    );
  }

  Widget _barisRincian(String kiri, String kanan,
      {Color? warna, bool tebal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          kiri,
          style: GoogleFonts.manrope(
            fontSize: tebal ? 12 : 11,
            fontWeight: tebal ? FontWeight.w800 : FontWeight.w500,
            color: AppColor.hitam,
          ),
        ),
        Text(
          kanan,
          style: GoogleFonts.manrope(
            fontSize: tebal ? 13 : 11,
            fontWeight: tebal ? FontWeight.w800 : FontWeight.w700,
            color: warna ?? (tebal ? AppColor.ungu : AppColor.hitam),
          ),
        ),
      ],
    );
  }

  Widget _judul(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColor.hitam,
        ),
      ),
    );
  }

  BoxDecoration _kartu() {
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