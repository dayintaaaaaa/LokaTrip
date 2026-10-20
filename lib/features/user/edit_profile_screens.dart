import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_color.dart';
import '../../widgets/sub_app_bar.dart';

class EditProfileScreens extends StatefulWidget {
  const EditProfileScreens({super.key});

  @override
  State<EditProfileScreens> createState() => _EditProfileScreensState();
}

class _EditProfileScreensState extends State<EditProfileScreens> {
  // TODO: isi awal dari data backend
  final _namaC = TextEditingController(text: 'Aditya Pratama');
  final _emailC = TextEditingController(text: 'aditya.pratama@email.com');
  final _teleponC = TextEditingController(text: '0812-3456-7890');

  DateTime _tanggalLahir = DateTime(1996, 8, 14);
  String _gender = 'Laki-laki';

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _teleponC.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (hasil != null) setState(() => _tanggalLahir = hasil);
  }

  void _simpan() {
    // TODO: kirim ke backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Perubahan berhasil disimpan',
          style: GoogleFonts.manrope(),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tgl =
        '${_tanggalLahir.day} ${_bulan[_tanggalLahir.month - 1]} ${_tanggalLahir.year}';

    return Scaffold(
      backgroundColor: AppColor.latar,
      body: Column(
        children: [
          const SubAppBar(title: 'Edit Profile'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fotoProfil(),
                  const SizedBox(height: 20),
                  Text(
                    'Data Pribadi Traveler',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColor.hitam,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pastikan informasi Anda akurat untuk tiket\n& atraksi wisata.',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: AppColor.abu,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _kartu(
                    label: 'Nama Lengkap',
                    child: _field(_namaC, Icons.badge_outlined),
                    info: 'Sesuai KTP / Paspor untuk kemudahan verifikasi e-tiket penerbangan dan atraksi wisata.',
                    infoIcon: Icons.info_outline,
                  ),
                  _kartu(
                    label: 'Email Akun',
                    child: _field(_emailC, Icons.mail_outline,
                        tipe: TextInputType.emailAddress),
                    info: 'E-tiket dan kode booking instan dikirimkan ke alamat email ini.',
                    infoIcon: Icons.mail_outline,
                  ),
                  _kartu(
                    label: 'Nomor Telepon / WhatsApp',
                    child: _field(_teleponC, null,
                        tipe: TextInputType.phone),
                    info: 'Nomor aktif untuk pengiriman notifikasi jadwal tur dan titik kumpul darurat.',
                    infoIcon: Icons.chat_bubble_outline,
                  ),
                  _kartu(
                    label: 'Tanggal Lahir',
                    labelKanan: 'Wajib untuk tiket penerbangan',
                    child: InkWell(
                      onTap: _pilihTanggal,
                      borderRadius: BorderRadius.circular(10),
                      child: _kotakIsi(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 16, color: AppColor.abu),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tgl,
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  color: AppColor.hitam,
                                ),
                              ),
                            ),
                            const Icon(Icons.edit_calendar_outlined,
                                size: 16, color: AppColor.abu),
                          ],
                        ),
                      ),
                    ),
                    info: 'Diperlukan untuk klaim asuransi perjalanan Lokatrip Care dan diskon usia traveler.',
                    infoIcon: Icons.shield_outlined,
                  ),
                  _kartu(
                    label: 'Jenis Kelamin',
                    child: Row(
                      children: [
                        Expanded(child: _pilihGender('Laki-laki', Icons.male)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _pilihGender('Perempuan', Icons.female)),
                      ],
                    ),
                    info: 'Harus cocok persis dengan identitas maskapai dan manifes kapal.',
                    infoIcon: Icons.flight_outlined,
                  ),
                ],
              ),
            ),
          ),

          // tombol simpan
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: AppColor.latar,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    'Simpan Perubahan',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.ungu,
                    foregroundColor: AppColor.putih,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fotoProfil() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: AppColor.biru,
                // TODO: foto dari backend
                child: Icon(Icons.person, size: 44, color: AppColor.putih),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColor.biru,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.putih, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 12, color: AppColor.putih),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Format JPG atau PNG, maks. 5MB',
            style: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              // TODO: hapus foto
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_outline,
                    size: 12, color: AppColor.ungu),
                const SizedBox(width: 3),
                Text(
                  'Hapus Foto',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColor.ungu,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartu({
    required String label,
    String? labelKanan,
    required Widget child,
    required String info,
    required IconData infoIcon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: label,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColor.hitam,
                    ),
                    children: [
                      TextSpan(
                        text: ' *',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (labelKanan != null)
                Text(
                  labelKanan,
                  style: GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(infoIcon, size: 12, color: AppColor.abu),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  info,
                  style: GoogleFonts.manrope(fontSize: 9, color: AppColor.abu),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kotakIsi({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.latar,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _field(
    TextEditingController c,
    IconData? icon, {
    TextInputType tipe = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColor.latar,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColor.abu),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: tipe,
              style: GoogleFonts.manrope(fontSize: 12, color: AppColor.hitam),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pilihGender(String nilai, IconData icon) {
    final aktif = _gender == nilai;
    return InkWell(
      onTap: () => setState(() => _gender = nilai),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: aktif ? AppColor.ungu.withValues(alpha: 0.08) : AppColor.latar,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: aktif ? AppColor.ungu : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: aktif ? AppColor.ungu : AppColor.abu.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 12, color: aktif ? AppColor.putih : AppColor.abu),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nilai,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                  color: AppColor.hitam,
                ),
              ),
            ),
            Icon(
              aktif ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 16,
              color: aktif ? AppColor.ungu : AppColor.abu,
            ),
          ],
        ),
      ),
    );
  }
}