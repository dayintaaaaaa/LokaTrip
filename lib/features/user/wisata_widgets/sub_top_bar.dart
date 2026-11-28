import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_color.dart';

// Bar kedua di bawah TopNavigator: lokasi + pencarian + filter.
class SubTopBar extends StatelessWidget {
  final String? lokasi; // null = baris lokasi disembunyikan
  final VoidCallback? onLokasiTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onFilterTap;

  const SubTopBar({
    super.key,
    this.lokasi,
    this.onLokasiTap,
    this.onSubmitted,
    this.onChanged,
    this.controller,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColor.putih,
      // atas 8 = jarak dari top navigasi
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // lokasi (tampil seperti kolom, lebar penuh)
          if (lokasi != null) ...[
            GestureDetector(
              onTap: onLokasiTap,
              child: Container(
                width: double.infinity,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColor.putih,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColor.ungu),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lokasi!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.hitam,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColor.abu,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // kolom pencarian + tombol filter
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColor.putih,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: AppColor.hitam.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 20, color: AppColor.abu),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.search,
                    style: GoogleFonts.manrope(fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isCollapsed: true,
                      hintText: 'Cari atraksi, tur candi, waterpark, wahana...',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppColor.abu,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 20,
                  color: AppColor.abu.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onFilterTap,
                  child: Row(
                    children: [
                      Icon(Icons.tune, size: 16, color: AppColor.ungu),
                      const SizedBox(width: 4),
                      Text(
                        'Filter',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColor.ungu,
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
}
