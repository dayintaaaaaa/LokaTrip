import 'package:flutter/material.dart';
import '../core/app_color.dart';

// Tombol hati bulat di atas gambar kartu.
// State dipegang oleh parent (mis. w.favorit), widget ini hanya menampilkan.
class TombolFavorit extends StatelessWidget {
  final bool favorit;
  final VoidCallback? onTap;

  const TombolFavorit({
    super.key,
    this.favorit = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: favorit
              ? AppColor.kuning
              : AppColor.putih.withValues(alpha: 0.95),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.favorite,
          size: 15,
          color: favorit ? AppColor.putih : AppColor.abu,
        ),
      ),
    );
  }
}