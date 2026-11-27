import 'package:flutter/material.dart';
import '../core/app_color.dart';

// Menampilkan gambar wisata dari URL Supabase/internet atau path asset.
// Jika path kosong atau gambar gagal dimuat, tampilkan placeholder.
class GambarWisata extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  const GambarWisata({
    super.key,
    this.path,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.image_not_supported_outlined,
    this.placeholderIconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColor.ungu.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        placeholderIcon,
        size: placeholderIconSize,
        color: AppColor.abu,
      ),
    );

    final p = path;
    final source = p?.trim();
    if (source == null || source.isEmpty) return placeholder;

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
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
      source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
