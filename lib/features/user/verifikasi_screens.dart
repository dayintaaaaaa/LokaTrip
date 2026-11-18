import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../widgets/sub_app_bar.dart';

class VerifikasiIdentitasScreens extends StatefulWidget {
  const VerifikasiIdentitasScreens({super.key});

  @override
  State<VerifikasiIdentitasScreens> createState() =>
      _VerifikasiIdentitasScreensState();
}

class _VerifikasiIdentitasScreensState
    extends State<VerifikasiIdentitasScreens> {
  int _tab = 0; // 0 = e-KTP, 1 = Paspor
  bool _tampilNik = false;
  bool _tampilPaspor = false;

  // TODO: ganti dengan data dari backend
  final String _nama = 'Aditya Pratama Putra';
  final String _tglVerifikasi = '14 Jul 2024';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Verifikasi Identitas'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bannerVerifikasi(),
                  const SizedBox(height: 14),
                  _tabSwitch(),
                  const SizedBox(height: 14),
                  if (_tab == 0) _kartuKtp() else _kartuPaspor(),
                  const SizedBox(height: 12),
                  _fotoDokumen(),
                  const SizedBox(height: 20),
                  Text(
                    'Keuntungan Akun Terverifikasi',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._keuntungan(),
                  const SizedBox(height: 6),
                  _tombolPerbarui(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== BANNER ==================
  Widget _bannerVerifikasi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.biru.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.biru.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColor.biru,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    size: 18, color: AppColor.putih),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akun Terverifikasi',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColor.ungu,
                      ),
                    ),
                    Text(
                      'TINGKAT 2 (IDENTITAS PENUH)',
                      style: GoogleFonts.manrope(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: AppColor.biru,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.kuning.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColor.kuning),
                    const SizedBox(width: 4),
                    Text(
                      _tglVerifikasi,
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColor.hitam,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Identitas Anda telah diverifikasi oleh Lokatrip dan disinkronkan dengan basis data kependudukan untuk kelancaran penerbitan tiket dan perlindungan asuransi.',
            style: GoogleFonts.manrope(
              fontSize: 10,
              height: 1.5,
              color: AppColor.hitam.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.putih.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline,
                    size: 12, color: AppColor.abu),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Data dienkripsi end-to-end (AES-256) berstandar resmi pariwisata. Hanya dibuka untuk manifes perjalanan & klaim darurat.',
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      height: 1.4,
                      color: AppColor.abu,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== TAB ==================
  Widget _tabSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColor.biru.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabItem(0, 'e-KTP Indonesia', Icons.badge_outlined),
          _tabItem(1, 'Paspor RI', Icons.menu_book_outlined),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label, IconData icon) {
    final aktif = _tab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = index),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: aktif ? AppColor.ungu : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14, color: aktif ? AppColor.putih : AppColor.hitam),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                  color: aktif ? AppColor.putih : AppColor.hitam,
                ),
              ),
              if (aktif) ...[
                const SizedBox(width: 4),
                const Icon(Icons.circle, size: 5, color: AppColor.putih),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================== KARTU e-KTP ==================
  Widget _kartuKtp() {
    return _kartuDasar(
      header: Row(
        children: [
          const Icon(Icons.account_balance, size: 22, color: AppColor.putih),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('REPUBLIK INDONESIA'),
                Text(
                  'Kartu Tanda Penduduk\nElektronik',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColor.putih,
                  ),
                ),
              ],
            ),
          ),
          _chipKartu('DUKCAPIL OK'),
        ],
      ),
      kotakNomor: _kotakNomor(
        label: 'NOMOR INDUK KEPENDUDUKAN',
        nilai: _tampilNik ? '3171012805950004' : '3171••••••••0004',
        tampil: _tampilNik,
        onToggle: () => setState(() => _tampilNik = !_tampilNik),
      ),
      isi: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _info('NAMA LENGKAP', _nama)),
            Expanded(child: _info('TEMPAT/TGL LAHIR', 'Jakarta, 18 Mei 1995')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _info('JENIS KELAMIN', 'Laki-laki')),
            Expanded(child: _info('MASA BERLAKU', 'Seumur Hidup')),
          ],
        ),
      ],
    );
  }

  // ================== KARTU PASPOR ==================
  Widget _kartuPaspor() {
    return _kartuDasar(
      header: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 20, color: AppColor.putih),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('REPUBLIK INDONESIA'),
                Text(
                  'Paspor / Passport',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColor.putih,
                  ),
                ),
              ],
            ),
          ),
          _chipKartu('IMIGRASI OK • ICAO'),
        ],
      ),
      kotakNomor: _kotakNomor(
        label: 'NOMOR PASPOR / PASSPORT NO.',
        nilai: _tampilPaspor ? 'B 8941232' : 'B 894••••2',
        tampil: _tampilPaspor,
        onToggle: () => setState(() => _tampilPaspor = !_tampilPaspor),
        badge: 'P • IDN',
      ),
      isi: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _info('NAMA LENGKAP / FULL NAME', _nama)),
            Expanded(
                child: _info('KEWARGANEGARAAN / NATIONALITY', 'INDONESIA')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _info('TEMPAT/TGL LAHIR / DOB', 'Jakarta, 18 Mei 1995')),
            Expanded(child: _info('JENIS KELAMIN / SEX', 'L / M')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _info('TGL PENGELUARAN / ISSUE', '22 Jan 2022')),
            Expanded(
                child: _info('HABIS BERLAKU / EXPIRY (R) TH', '22 Jan 2032')),
          ],
        ),
        const SizedBox(height: 10),
        _info('KANTOR PENERBIT / ISSUING OFFICE', 'Kanim Jakarta Selatan'),
      ],
    );
  }

  Widget _kartuDasar({
    required Widget header,
    required Widget kotakNomor,
    required List<Widget> isi,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.ungu,
            Color.lerp(AppColor.ungu, AppColor.biru, 0.45)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.ungu.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 12),
          kotakNomor,
          const SizedBox(height: 14),
          ...isi,
        ],
      ),
    );
  }

  Widget _chipKartu(String teks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.putih.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColor.putih.withValues(alpha: 0.4)),
      ),
      child: Text(
        teks,
        style: GoogleFonts.manrope(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: AppColor.putih,
        ),
      ),
    );
  }

  Widget _kotakNomor({
    required String label,
    required String nilai,
    required bool tampil,
    required VoidCallback onToggle,
    String? badge,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.putih.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.putih.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _label(label)),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.putih.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.manrope(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColor.putih,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  nilai,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColor.putih,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  tampil
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColor.putih.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String teks) {
    return Text(
      teks,
      style: GoogleFonts.manrope(
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColor.putih.withValues(alpha: 0.75),
      ),
    );
  }

  Widget _info(String label, String nilai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 2),
        Text(
          nilai,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColor.putih,
          ),
        ),
      ],
    );
  }

  // ================== FOTO DOKUMEN ==================
  Widget _fotoDokumen() {
    final ktp = _tab == 0;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          // TODO: ganti dengan Image.network(fotoDokumenDariBackend)
          Container(
            width: 64,
            height: 44,
            decoration: BoxDecoration(
              color: AppColor.biru.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColor.ungu,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'TERVERIFIKASI',
                style: GoogleFonts.manrope(
                  fontSize: 6,
                  fontWeight: FontWeight.w800,
                  color: AppColor.putih,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ktp
                      ? 'Foto e-KTP Asli Terunggah'
                      : 'Foto Paspor Asli Terunggah (Halaman Biodata)',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ktp
                      ? 'Resolusi tinggi • Sisi depan jelas'
                      : 'Halaman 2 biodata jelas • Tanda tangan & MRZ terbaca',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    color: AppColor.abu,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              // TODO: perbesar foto dokumen
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColor.biru.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.zoom_in, size: 16, color: AppColor.ungu),
            ),
          ),
        ],
      ),
    );
  }

  // ================== KEUNTUNGAN ==================
  List<Widget> _keuntungan() {
    final data = _tab == 0
        ? const [
            _Untung(
              Icons.qr_code_scanner,
              'Check-in Wisata Instan',
              'Cukup scan barcode Lokatrip di gate Borobudur, GWK Bali, & Jatim Park tanpa antre loket verifikasi fisik KTP.',
            ),
            _Untung(
              Icons.shield_outlined,
              'Asuransi Perjalanan Instan',
              'Polis perlindungan kecelakaan & pembatalan otomatis terbit legal atas nama Aditya Pratama Putra.',
            ),
            _Untung(
              Icons.credit_card,
              'Limit Pemesanan Rp 50.000.000',
              'Akses bebas booking paket rombongan open-trip internasional & sewa mobil tanpa deposit jaminan fisik.',
            ),
          ]
        : const [
            _Untung(
              Icons.qr_code_scanner,
              'Check-in Wisata & Imigrasi Instan',
              'Cukup scan paspor digital Lokatrip untuk autogate bandara mitra & gerbang atraksi internasional tanpa verifikasi fisik manual.',
            ),
            _Untung(
              Icons.flight_takeoff,
              'Validasi Otomatis Tiket Mancanegara',
              'Pemesanan penerbangan internasional & paket open-trip luar negeri langsung tervalidasi dengan legalitas terpadu ICAO.',
            ),
            _Untung(
              Icons.shield_outlined,
              'Asuransi Perjalanan Internasional Legalitas Terjamin',
              'Perlindungan medis global dan kompensasi delay penerbangan langsung aktif legal atas nama Aditya Pratama Putra.',
            ),
          ];

    return data
        .map((u) => Container(
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
                    child: Icon(u.icon, size: 16, color: AppColor.ungu),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.judul,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColor.hitam,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          u.isi,
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
            ))
        .toList();
  }

  Widget _tombolPerbarui() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: arahkan ke halaman unggah dokumen identitas
        },
        icon: const Icon(Icons.upload_file, size: 18),
        label: Text(
          'Perbarui Dokumen Identitas',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.biru.withValues(alpha: 0.18),
          foregroundColor: AppColor.ungu,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

class _Untung {
  final IconData icon;
  final String judul;
  final String isi;
  const _Untung(this.icon, this.judul, this.isi);
}