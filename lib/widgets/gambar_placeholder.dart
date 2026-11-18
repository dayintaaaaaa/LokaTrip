import 'package:flutter/material.dart';
import '../core/app_color.dart';

class GambarPlaceholder extends StatelessWidget {
  final Color warna;
  final double? tinggi;
  final double? lebar;
  final IconData icon;
  final double iconSize;
  final Widget? child; // badge / teks yang ditumpuk di atas gambar

  const GambarPlaceholder({
    super.key,
    required this.warna,
    this.tinggi,
    this.lebar,
    this.icon = Icons.landscape_outlined,
    this.iconSize = 40,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: ganti dengan Image.network(urlDariBackend, fit: BoxFit.cover)
    return Container(
      height: tinggi,
      width: lebar ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            warna.withValues(alpha: 0.55),
            warna.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Icon(icon,
                size: iconSize, color: AppColor.putih.withValues(alpha: 0.5)),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}