import 'package:flutter/material.dart';
import '../core/app_color.dart';

// Menampilkan gambar wisata dari URL (Supabase) atau path asset (dummy).
// Kalau path kosong atau gambar gagal dimuat, tampil kotak abu dengan
// ikon gambar rusak.
class GambarWisata extends StatelessWidget {
  final String? path;
  final BoxFit fit;

  const GambarWisata({super.key, this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColor.ungu.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.broken_image_outlined,
        size: 32,
        color: AppColor.abu,
      ),
    );

    final p = path;
    if (p == null || p.isEmpty) return placeholder;

    // URL dari Supabase Storage / internet
    if (p.startsWith('http')) {
      return Image.network(
        p,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => placeholder,
        // selama memuat, tampil kotak polos (tanpa ikon rusak)
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColor.ungu.withValues(alpha: 0.08),
              ),
      );
    }

    // path asset (data dummy)
    return Image.asset(
      p,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}