import 'package:flutter/material.dart';
import '../core/app_color.dart';

// Menampilkan gambar wisata dari URL Supabase/internet atau path asset.
// Jika path kosong atau gambar gagal dimuat, tampilkan placeholder.
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
      child: Icon(Icons.broken_image_outlined, size: 32, color: AppColor.abu),
    );

    final p = path;
    if (p == null || p.isEmpty) return placeholder;

    if (p.startsWith('http://') || p.startsWith('https://')) {
      return Image.network(
        p,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => placeholder,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColor.ungu.withValues(alpha: 0.08),
          );
        },
      );
    }

    return Image.asset(
      p,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
