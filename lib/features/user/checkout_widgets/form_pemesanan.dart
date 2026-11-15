import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

// ---------- validasi (dipakai juga oleh screen untuk fokus ke field error) ----------

String? validasiNama(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Nama lengkap wajib diisi';
  if (t.length < 3) return 'Nama terlalu pendek';
  return null;
}

String? validasiEmail(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Alamat email wajib diisi';
  final cocok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
  return cocok ? null : 'Format email tidak valid';
}

String? validasiTelepon(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Nomor WhatsApp wajib diisi';
  final angka = t.replaceAll(RegExp(r'[\s\-+]'), '');
  final cocok = RegExp(r'^(62|0)8\d{8,11}$').hasMatch(angka);
  return cocok ? null : 'Gunakan nomor Indonesia, contoh 0812-3456-7890';
}

// Kartu "Data Pemesan". Stateless: controller, fokus, dan switch dipegang screen.
class FormPemesan extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController namaC;
  final TextEditingController emailC;
  final TextEditingController teleponC;
  final FocusNode namaF;
  final FocusNode emailF;
  final FocusNode teleponF;
  final bool pakaiProfil;
  final ValueChanged<bool> onPakaiProfil;
  final VoidCallback onBerubah; // dipanggil tiap isi field berubah

  const FormPemesan({
    super.key,
    required this.formKey,
    required this.namaC,
    required this.emailC,
    required this.teleponC,
    required this.namaF,
    required this.emailF,
    required this.teleponF,
    required this.pakaiProfil,
    required this.onPakaiProfil,
    required this.onBerubah,
  });

  static const _merah = Color(0xFFE53935);
  static const _isian = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.putih,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.abu.withValues(alpha: 0.2)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // judul
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColor.ungu.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: AppColor.ungu,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Data Pemesan',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColor.hitam,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // pakai profil akun
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _isian,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_box_outlined,
                    size: 18,
                    color: AppColor.ungu,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gunakan profil akun Lokatrip',
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColor.hitam,
                      ),
                    ),
                  ),
                  Switch(
                    value: pakaiProfil,
                    onChanged: onPakaiProfil,
                    activeTrackColor: AppColor.ungu,
                    inactiveTrackColor: AppColor.abu.withValues(alpha: 0.35),
                    thumbColor: WidgetStateProperty.all(AppColor.putih),
                    trackOutlineColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _label('Nama Lengkap'),
            _isianTeks(
              controller: namaC,
              fokus: namaF,
              hint: 'Nama sesuai kartu identitas',
              helper: 'Sesuai kartu identitas untuk validasi tiket di lokasi.',
              ikon: Icons.check_circle_outline,
              valid: validasiNama(namaC.text) == null,
              validator: validasiNama,
              tipe: TextInputType.name,
              kapital: TextCapitalization.words,
              aksi: TextInputAction.next,
              berikutnya: emailF,
            ),
            const SizedBox(height: 10),

            _label('Alamat Email'),
            _isianTeks(
              controller: emailC,
              fokus: emailF,
              hint: 'nama@email.com',
              helper: 'E-tiket dan kode booking QR akan dikirimkan ke email ini.',
              ikon: Icons.mail_outline,
              valid: validasiEmail(emailC.text) == null,
              validator: validasiEmail,
              tipe: TextInputType.emailAddress,
              aksi: TextInputAction.next,
              berikutnya: teleponF,
            ),
            const SizedBox(height: 10),

            _label('Nomor WhatsApp'),
            _isianTeks(
              controller: teleponC,
              fokus: teleponF,
              hint: '0812-3456-7890',
              helper: 'Info titik temu & pengingat kunjungan dikirim via WhatsApp.',
              ikon: Icons.chat_outlined,
              valid: validasiTelepon(teleponC.text) == null,
              validator: validasiTelepon,
              tipe: TextInputType.phone,
              aksi: TextInputAction.done,
              format: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'))],
            ),
          ],
        ),
      ),
    );
  }

  // "Nama Lengkap *"
  Widget _label(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: teks,
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColor.hitam,
              ),
            ),
            TextSpan(
              text: ' *',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _merah,
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _garis(Color warna) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: warna),
    );
  }

  Widget _isianTeks({
    required TextEditingController controller,
    required FocusNode fokus,
    required String hint,
    required String helper,
    required IconData ikon,
    required bool valid,
    required String? Function(String?) validator,
    required TextInputType tipe,
    required TextInputAction aksi,
    TextCapitalization kapital = TextCapitalization.none,
    FocusNode? berikutnya,
    List<TextInputFormatter>? format,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: fokus,
      keyboardType: tipe,
      textInputAction: aksi,
      textCapitalization: kapital,
      inputFormatters: format,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (_) => onBerubah(),
      onFieldSubmitted: (_) {
        if (berikutnya != null) berikutnya.requestFocus();
      },
      style: GoogleFonts.manrope(fontSize: 12.5, color: AppColor.hitam),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(fontSize: 12.5, color: AppColor.abu),
        filled: true,
        fillColor: _isian,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: _garis(Colors.transparent),
        enabledBorder: _garis(Colors.transparent),
        focusedBorder: _garis(AppColor.ungu.withValues(alpha: 0.5)),
        errorBorder: _garis(_merah.withValues(alpha: 0.6)),
        focusedErrorBorder: _garis(_merah),
        suffixIcon: Icon(
          ikon,
          size: 18,
          color: valid ? AppColor.ungu : AppColor.abu.withValues(alpha: 0.5),
        ),
        helperText: helper,
        helperMaxLines: 2,
        helperStyle: GoogleFonts.manrope(fontSize: 10, color: AppColor.abu),
        errorStyle: GoogleFonts.manrope(fontSize: 10, color: _merah),
      ),
    );
  }
}