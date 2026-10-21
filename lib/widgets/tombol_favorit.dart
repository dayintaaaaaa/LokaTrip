import 'package:flutter/material.dart';
import '../core/app_color.dart';

// Tombol hati bulat di atas gambar kartu. Baru tampilan, belum disimpan.
class TombolFavorit extends StatefulWidget {
  final bool awal;
  final ValueChanged<bool>? onChanged;

  const TombolFavorit({super.key, this.awal = false, this.onChanged});

  @override
  State<TombolFavorit> createState() => _TombolFavoritState();
}

class _TombolFavoritState extends State<TombolFavorit> {
  late bool _aktif;

  @override
  void initState() {
    super.initState();
    _aktif = widget.awal;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _aktif = !_aktif);
        widget.onChanged?.call(_aktif);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColor.putih.withValues(alpha: 0.95),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _aktif ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: _aktif ? AppColor.kuning : AppColor.abu,
        ),
      ),
    );
  }
}