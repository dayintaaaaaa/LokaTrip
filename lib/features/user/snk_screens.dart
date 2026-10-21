import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../widgets/sub_app_bar.dart';

// TODO: ganti model ini dengan data dari backend / CMS
class _Ringkasan {
  final IconData icon;
  final String judul;
  final String isi;
  const _Ringkasan(this.icon, this.judul, this.isi);
}

class _Pasal {
  final IconData icon;
  final String judul;
  final String subjudul;
  final List<String> butir;
  const _Pasal(this.icon, this.judul, this.subjudul, this.butir);
}

class SnkScreens extends StatelessWidget {
  const SnkScreens({super.key});

  static const List<_Ringkasan> _ringkasan = [
    _Ringkasan(
      Icons.verified_user_outlined,
      'Keamanan Data Terenkripsi',
      'Informasi KTP dan paspor wisatawan dienkripsi aman 256-bit dan hanya dibagikan ke gerbang resmi destinasi untuk verifikasi e-tiket.',
    ),
    _Ringkasan(
      Icons.payments_outlined,
      'Tanpa Biaya Tersembunyi',
      'Total nominal yang tampil di layar pembayaran akhir adalah harga final termasuk retribusi taman nasional & asuransi perjalanan legal.',
    ),
    _Ringkasan(
      Icons.lock_outline,
      'Pembatalan Non-Refundable',
      'Setiap pemesanan bersifat final dan tidak dapat dibatalkan atau dikembalikan dengan alasan apa pun, termasuk pembatalan akibat cuaca atau kendala pribadi.',
    ),
  ];

  static const List<_Pasal> _pasal = [
    _Pasal(
      Icons.badge_outlined,
      '1. Ketentuan Akun & Syarat Usia',
      'Pendaftaran akun Sarah Anindita & keamanan kredensial',
      [
        '1.1. Pengguna wajib berusia minimal 18 tahun atau legal untuk membuat akun mandiri di platform LokaTrip.',
        '1.2. Pengguna bertanggung jawab penuh atas segala aktivitas transaksi, perlindungan sandi, serta kode verifikasi OTP yang dikirimkan melalui nomor ponsel terdaftar.',
        '1.3. LokaTrip berhak menangguhkan akun secara sepihak jika ditemukan indikasi peretasan akun atau pemalsuan identitas pengunjung demi keamanan.',
      ],
    ),
    _Pasal(
      Icons.storage_outlined,
      '2. Pengumpulan & Penggunaan Data Pribadi',
      'Nama, NIK KTP, geolokasi, dan rekaman pembayaran',
      ['Isi pasal 2 diambil dari backend.'], // TODO
    ),
    _Pasal(
      Icons.autorenew,
      '3. Pembatalan, Reschedule & Refund',
      'Prosedur pengembalian dana tiket & keadaan kahar (force majeure)',
      ['Isi pasal 3 diambil dari backend.'], // TODO
    ),
    _Pasal(
      Icons.copyright_outlined,
      '4. Hak Kekayaan Intelektual & Mitra Resmi',
      'Lisensi foto atraksi, hak cipta materi, & sertifikasi pengelola',
      ['Isi pasal 4 diambil dari backend.'], // TODO
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Syarat & Kebijakan Privasi'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kartuKomitmen(),
                  const SizedBox(height: 18),

                  Text(
                    'DAFTAR BAB & KEBIJAKAN',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColor.hitam.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ringkasan Inti',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                      ),
                      Text(
                        '3 Poin Pokok',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColor.kuning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._ringkasan.map(_kartuRingkasan),

                  const SizedBox(height: 10),
                  Text(
                    'Rincian Pasal & Ketentuan',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    _pasal.length,
                    (i) => _kartuPasal(_pasal[i], terbuka: i == 0),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Dengan terus menggunakan aplikasi LokaTrip, Anda\nmenyetujui pembaruan kebijakan privasi kami.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        color: AppColor.abu,
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

  // ================== KARTU KOMITMEN ==================
  Widget _kartuKomitmen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.biru.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_outlined,
                    size: 22, color: AppColor.ungu),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _chipKecil('VERSI 3.14.0', AppColor.ungu),
                        const SizedBox(width: 6),
                        Text(
                          'Diperbarui: 1 Jan 2025',
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            color: AppColor.abu,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Perlindungan & Komitmen\nPrivasi',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColor.hitam,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LokaTrip menjunjung tinggi privasi data sesuai UU Perlindungan Data Pribadi (PDP) No. 27 Tahun 2022.',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        height: 1.4,
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _badgeJaminan(Icons.lock_outline, 'Enkripsi SHA-256'),
              _badgeJaminan(Icons.gavel_outlined, 'Yurisdiksi RI'),
              _badgeJaminan(Icons.verified_outlined, 'Mitra Resmi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeJaminan(IconData icon, String teks) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColor.ungu),
        const SizedBox(width: 4),
        Text(
          teks,
          style: GoogleFonts.manrope(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColor.ungu,
          ),
        ),
      ],
    );
  }

  Widget _chipKecil(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: warna,
        ),
      ),
    );
  }

  // ================== RINGKASAN ==================
  Widget _kartuRingkasan(_Ringkasan r) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.biru.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(r.icon, size: 16, color: AppColor.ungu),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.judul,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  r.isi,
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    height: 1.4,
                    color: AppColor.abu,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== PASAL (bisa dibuka-tutup) ==================
  Widget _kartuPasal(_Pasal p, {bool terbuka = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: terbuka,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColor.abu,
          collapsedIconColor: AppColor.abu,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.ungu.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(p.icon, size: 16, color: AppColor.ungu),
          ),
          title: Text(
            p.judul,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColor.hitam,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              p.subjudul,
              style: GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
            ),
          ),
          children: p.butir
              .map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    b,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      height: 1.5,
                      color: AppColor.hitam.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
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