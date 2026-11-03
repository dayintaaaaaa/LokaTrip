import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../core/format.dart';
import '../../widgets/sub_app_bar.dart';

// TODO: ganti model ini dengan model dari backend
class _Mutasi {
  final String judul;
  final DateTime waktu;
  final int jumlah; // negatif = poin terpakai, positif = poin masuk
  final int sisa;

  const _Mutasi(this.judul, this.waktu, this.jumlah, this.sisa);
}

class _GrupBulan {
  final String bulan;
  final List<_Mutasi> items;

  const _GrupBulan(this.bulan, this.items);
}

class RiwayatPoinScreens extends StatefulWidget {
  const RiwayatPoinScreens({super.key});

  @override
  State<RiwayatPoinScreens> createState() => _RiwayatPoinScreensState();
}

class _RiwayatPoinScreensState extends State<RiwayatPoinScreens> {
  final int _saldoAktif = 24500;
  final int _akanKedaluwarsa = 1200;
  final String _tglKedaluwarsa = '31 Des 2024';

  // rentang tanggal yang dipilih user (null = tampilkan semua)
  DateTimeRange? _rentang;

  static const _namaBulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static final List<_GrupBulan> _data = [
    _GrupBulan('OKTOBER 2024', [
      _Mutasi('Tukar Voucher Wisata', DateTime(2024, 10, 24, 14, 20), -8000, 24500),
      _Mutasi('Cashback Tiket Waterbom Bali', DateTime(2024, 10, 23, 10, 15), 2400, 32500),
      _Mutasi('Ulasan Foto Candi Borobudur', DateTime(2024, 10, 18, 19, 40), 500, 30100),
    ]),
    _GrupBulan('SEPTEMBER 2024', [
      _Mutasi('Reward Misi Jelajah Nusantara', DateTime(2024, 9, 30, 23, 59), 2000, 29600),
      _Mutasi('Potongan Tiket GWK Bali', DateTime(2024, 9, 15, 8, 30), -5000, 27600),
      _Mutasi('Bonus Ulang Tahun Anggota', DateTime(2024, 8, 14, 0, 0), 1000, 32600),
    ]),
  ];

  // ---------------- format tanggal ----------------
  String _tgl(DateTime d) => '${d.day} ${_namaBulan[d.month - 1]} ${d.year}';

  String _jam(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _waktuLengkap(DateTime d) => '${_tgl(d)} • ${_jam(d)} WIB';

  // ---------------- kalender ----------------
  Future<void> _pilihTanggal() async {
    // TODO: kalau sudah pakai data backend, ganti ke 3 bulan terakhir
    final semua = _data.expand((g) => g.items).map((m) => m.waktu).toList()
      ..sort();
    final awalData = DateTime(semua.first.year, semua.first.month, semua.first.day);
    final akhirData = DateTime(semua.last.year, semua.last.month, semua.last.day);

    final hasil = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange:
          _rentang ?? DateTimeRange(start: awalData, end: akhirData),
      helpText: 'Pilih rentang tanggal',
      saveText: 'Terapkan',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.ungu,
              onPrimary: AppColor.putih,
              onSurface: AppColor.hitam,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hasil != null) {
      setState(() => _rentang = hasil);
    }
  }

  // data setelah difilter, grup yang kosong dibuang
  List<_GrupBulan> get _tampil {
    final r = _rentang;
    if (r == null) return _data;

    final awal = DateTime(r.start.year, r.start.month, r.start.day);
    final akhir = DateTime(r.end.year, r.end.month, r.end.day, 23, 59, 59);

    return _data
        .map((g) => _GrupBulan(
              g.bulan,
              g.items
                  .where((m) => !m.waktu.isBefore(awal) && !m.waktu.isAfter(akhir))
                  .toList(),
            ))
        .where((g) => g.items.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tampil = _tampil;

    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          SubAppBar(
            title: 'Riwayat Poin',
            trailing: IconButton(
              onPressed: _pilihTanggal,
              icon: Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: _rentang != null ? AppColor.ungu : AppColor.hitam,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _ringkasan(),

                // chip rentang tanggal aktif
                if (_rentang != null) ...[
                  const SizedBox(height: 12),
                  _chipRentang(_rentang!),
                ],

                const SizedBox(height: 12),

                if (tampil.isEmpty)
                  _kosong()
                else
                  ...tampil.map(_grup),

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

  // ---------------- chip rentang tanggal ----------------
  Widget _chipRentang(DateTimeRange r) {
    final sama = r.start == r.end;
    final teks = sama ? _tgl(r.start) : '${_tgl(r.start)} – ${_tgl(r.end)}';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: AppColor.ungu.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 12, color: AppColor.ungu),
            const SizedBox(width: 6),
            Text(
              teks,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColor.ungu,
              ),
            ),
            const SizedBox(width: 4),
            // hapus filter
            GestureDetector(
              onTap: () => setState(() => _rentang = null),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 15, color: AppColor.ungu),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- kosong ----------------
  Widget _kosong() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined,
              size: 36, color: AppColor.abu.withValues(alpha: 0.7)),
          const SizedBox(height: 10),
          Text(
            'Tidak ada transaksi',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColor.hitam,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Coba pilih rentang tanggal yang lain',
            style: GoogleFonts.manrope(fontSize: 11, color: AppColor.abu),
          ),
        ],
      ),
    );
  }

  // ---------------- ringkasan saldo ----------------
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

  // ---------------- grup per bulan ----------------
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

  // ---------------- satu baris mutasi ----------------
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
                  _waktuLengkap(m.waktu),
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