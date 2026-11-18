import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

const String kotaSemua = '__semua__';

// Hasil: nama kota, kotaSemua, atau null (ditutup tanpa memilih).
Future<String?> tampilkanPilihKota(
  BuildContext context, {
  required List<String> daftar,
  String? terpilih,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColor.putih,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.abu.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pilih Lokasi',
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColor.hitam,
                ),
              ),
            ),
            ListTile(
              title: Text('Semua Lokasi', style: GoogleFonts.manrope()),
              trailing: terpilih == null
                  ? Icon(Icons.check, color: AppColor.ungu)
                  : null,
              onTap: () => Navigator.pop(sheetContext, kotaSemua),
            ),
            for (final k in daftar)
              ListTile(
                title: Text(k, style: GoogleFonts.manrope()),
                trailing: terpilih == k
                    ? Icon(Icons.check, color: AppColor.ungu)
                    : null,
                onTap: () => Navigator.pop(sheetContext, k),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}