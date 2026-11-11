import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';
import '../../../core/format_tanggal.dart';
import '../../../models/ketersediaan_dummy.dart';

// Kartu "Pilih Tanggal Kunjungan": kalender bulanan + harga per hari,
// legenda, dan info sisa kuota. Stateless: bulan & tanggal dipegang screen.
class KalenderKunjungan extends StatelessWidget {
  final DateTime bulan; // tanggal 1 pada bulan yang ditampilkan
  final DateTime terpilih;
  final DateTime awal; // tanggal paling awal yang boleh dipesan
  final DateTime akhir; // tanggal paling akhir yang boleh dipesan
  final Ketersediaan Function(DateTime) ketersediaan;
  final ValueChanged<DateTime> onPilih;
  final ValueChanged<int> onGantiBulan; // -1 = bulan lalu, 1 = bulan depan

  const KalenderKunjungan({
    super.key,
    required this.bulan,
    required this.terpilih,
    required this.awal,
    required this.akhir,
    required this.ketersediaan,
    required this.onPilih,
    required this.onGantiBulan,
  });

  static const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _jarak = 6.0;

  bool _sama(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // 375000 -> "375rb", 1500000 -> "1,5jt"
  static String _ringkas(int h) {
    if (h >= 1000000) {
      final jt = h / 1000000;
      final teks = jt == jt.roundToDouble()
          ? '${jt.round()}'
          : jt.toStringAsFixed(1).replaceAll('.', ',');
      return '${teks}jt';
    }
    return '${(h / 1000).round()}rb';
  }

  @override
  Widget build(BuildContext context) {
    final bisaMundur = bulan.isAfter(DateTime(awal.year, awal.month));
    final bisaMaju = bulan.isBefore(DateTime(akhir.year, akhir.month));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pilih Tanggal Kunjungan',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _pilBulan(bisaMundur, bisaMaju),
            ],
          ),
          const SizedBox(height: 12),
          _garis(),
          const SizedBox(height: 12),
          _namaHari(),
          const SizedBox(height: 8),
          _grid(),
          const SizedBox(height: 12),
          _garis(),
          const SizedBox(height: 12),
          _legenda(),
          const SizedBox(height: 12),
          _infoKuota(),
        ],
      ),
    );
  }

  Widget _garis() =>
      Divider(height: 1, color: AppColor.abu.withValues(alpha: 0.15));

  // pil "< Oktober 2024 >"
  Widget _pilBulan(bool bisaMundur, bool bisaMaju) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColor.ungu.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _panah(Icons.chevron_left, bisaMundur, -1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '${namaBulan(bulan.month)} ${bulan.year}',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColor.hitam,
              ),
            ),
          ),
          _panah(Icons.chevron_right, bisaMaju, 1),
        ],
      ),
    );
  }

  Widget _panah(IconData ikon, bool aktif, int arah) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aktif ? () => onGantiBulan(arah) : null,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          ikon,
          size: 18,
          color: aktif ? AppColor.ungu : AppColor.abu.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // Sen Sel Rab ... (Sab biru, Min kuning)
  Widget _namaHari() {
    return Row(
      children: [
        for (var i = 0; i < _hari.length; i++) ...[
          if (i > 0) const SizedBox(width: _jarak),
          Expanded(
            child: Center(
              child: Text(
                _hari[i],
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: i == 5
                      ? AppColor.ungu
                      : i == 6
                          ? AppColor.kuning
                          : AppColor.abu,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _grid() {
    final geser = bulan.weekday - 1; // Senin = 0
    final jumlahHari = DateTime(bulan.year, bulan.month + 1, 0).day;

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: _jarak,
      crossAxisSpacing: _jarak,
      childAspectRatio: 0.78,
      children: [
        for (var i = 0; i < geser; i++) const SizedBox(),
        for (var d = 1; d <= jumlahHari; d++)
          _sel(DateTime(bulan.year, bulan.month, d)),
      ],
    );
  }

  Widget _sel(DateTime t) {
    final dalamRentang = !t.isBefore(awal) && !t.isAfter(akhir);
    final info = dalamRentang ? ketersediaan(t) : null;
    final bisa = info != null && !info.penuh;
    final dipilih = _sama(t, terpilih);

    String? sub;
    if (info != null) {
      sub = info.penuh
          ? 'Penuh'
          : dipilih
              ? 'Rp${_ringkas(info.harga)}'
              : _ringkas(info.harga);
    }

    final warnaAngka = dipilih
        ? AppColor.putih
        : !dalamRentang
            ? AppColor.abu.withValues(alpha: 0.4)
            : !bisa
                ? AppColor.abu.withValues(alpha: 0.6)
                : AppColor.hitam;
    final warnaSub = dipilih
        ? AppColor.putih
        : !bisa
            ? AppColor.abu.withValues(alpha: 0.6)
            : AppColor.ungu;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: bisa ? () => onPilih(t) : null,
      child: Container(
        decoration: BoxDecoration(
          color: dipilih
              ? AppColor.biru
              : bisa
                  ? AppColor.putih
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: bisa && !dipilih
              ? Border.all(color: AppColor.abu.withValues(alpha: 0.3))
              : null,
          boxShadow: dipilih
              ? [
                  BoxShadow(
                    color: AppColor.biru.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${t.day}',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: warnaAngka,
              ),
            ),
            if (sub != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    sub,
                    style: GoogleFonts.manrope(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: warnaSub,
                    ),
                  ),
                ),
              ),
            if (dipilih) ...[
              const SizedBox(height: 3),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColor.putih,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legenda() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _itemLegenda(AppColor.biru, null, 'Terpilih'),
        _itemLegenda(
          AppColor.ungu.withValues(alpha: 0.12),
          AppColor.ungu.withValues(alpha: 0.3),
          'Tersedia',
        ),
        _itemLegenda(AppColor.abu.withValues(alpha: 0.3), null, 'Kuota Penuh'),
      ],
    );
  }

  Widget _itemLegenda(Color warna, Color? garis, String teks) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: warna,
            shape: BoxShape.circle,
            border: garis == null ? null : Border.all(color: garis),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          teks,
          style: GoogleFonts.manrope(fontSize: 9.5, color: AppColor.abu),
        ),
      ],
    );
  }

  // "Sisa kuota tanggal 28 Okt: 14 tiket tersedia"
  Widget _infoKuota() {
    final kuota = ketersediaan(terpilih).kuota;
    final dasar = GoogleFonts.manrope(
      fontSize: 10.5,
      color: AppColor.hitam,
      height: 1.4,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.ungu.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 15, color: AppColor.ungu),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: dasar,
                children: [
                  const TextSpan(text: 'Sisa kuota tanggal '),
                  TextSpan(
                    text:
                        '${terpilih.day} ${namaBulanSingkat(terpilih.month)}',
                    style: dasar.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColor.ungu,
                    ),
                  ),
                  const TextSpan(text: ': '),
                  TextSpan(
                    text: '$kuota tiket',
                    style: dasar.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColor.kuning,
                    ),
                  ),
                  const TextSpan(text: ' tersedia'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}