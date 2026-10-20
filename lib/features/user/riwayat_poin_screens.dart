import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format.dart';
import '../../widgets/sub_app_bar.dart';

// TODO: ganti model ini dengan model dari backend
class _Mutasi {
  final String judul;
  final String waktu;
  final int jumlah; // negatif = poin terpakai, positif = poin masuk
  final int sisa;

  const _Mutasi(this.judul, this.waktu, this.jumlah, this.sisa);
}

class _GrupBulan {
  final String bulan;
  final List<_Mutasi> items;

  const _GrupBulan(this.bulan, this.items);
}

class RiwayatPoinScreens extends StatelessWidget {
  const RiwayatPoinScreens({super.key});

  final int _saldoAktif = 24500;
  final int _akanKedaluwarsa = 1200;
  final String _tglKedaluwarsa = '31 Des 2024';

  static const List<_GrupBulan> _data = [
    _GrupBulan('OKTOBER 2024', [
      _Mutasi('Tukar Voucher Wisata', '24 Okt 2024 • 14:20 WIB', -8000, 24500),
      _Mutasi('Cashback Tiket Waterbom Bali', '23 Okt 2024 • 10:15 WIB', 2400, 32500),
      _Mutasi('Ulasan Foto Candi Borobudur', '18 Okt 2024 • 19:40 WIB', 500, 30100),
    ]),
    _GrupBulan('SEPTEMBER 2024', [
      _Mutasi('Reward Misi Jelajah Nusantara', '30 Sep 2024 • 23:59 WIB', 2000, 29600),
      _Mutasi('Potongan Tiket GWK Bali', '15 Sep 2024 • 08:30 WIB', -5000, 27600),
      _Mutasi('Bonus Ulang Tahun Anggota', '14 Agu 2024 • 00:00 WIB', 1000, 32600),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          SubAppBar(
            title: 'Riwayat Poin',
            trailing: IconButton(
              onPressed: () {
                // TODO: filter berdasarkan tanggal
              },
              icon: const Icon(Icons.calendar_today_outlined,
                  size: 20, color: AppColor.hitam),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _ringkasan(),
                const SizedBox(height: 12),
                ..._data.map(_grup),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColor.abu.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Menampilkan mutasi poin 3 bulan terakhir',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: AppColor.abu,
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

  Widget _ringkasan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Saldo Poin Aktif',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: AppColor.hitam,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.kuning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        size: 11, color: AppColor.kuning),
                    const SizedBox(width: 3),
                    Text(
                      '${formatAngka(_akanKedaluwarsa)} Kedaluwarsa',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColor.kuning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAngka(_saldoAktif),
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColor.ungu,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Poin',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.ungu,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _tglKedaluwarsa,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: AppColor.abu,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _grup(_GrupBulan g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.hitam.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColor.ungu.withValues(alpha: 0.06),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  g.bulan,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                Text(
                  '${g.items.length} Transaksi',
                  style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
                ),
              ],
            ),
          ),
          ...List.generate(g.items.length, (i) {
            return Column(
              children: [
                _baris(g.items[i]),
                if (i != g.items.length - 1)
                  Divider(
                    height: 1,
                    color: AppColor.abu.withValues(alpha: 0.2),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _baris(_Mutasi m) {
    final keluar = m.jumlah < 0;
    final warna = keluar ? AppColor.kuning : AppColor.biru;
    final tanda = keluar ? '' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              keluar ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: warna,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.judul,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  m.waktu,
                  style: GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$tanda${formatAngka(m.jumlah)} Poin',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: warna,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sisa: ${formatAngka(m.sisa)}',
                style: GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
              ),
            ],
          ),
        ],
      ),
    );
  }
}