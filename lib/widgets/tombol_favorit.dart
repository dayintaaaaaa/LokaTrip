import 'package:flutter/material.dart';
import '../core/app_color.dart';
import '../core/favorite_store.dart';

class TombolFavorit extends StatelessWidget {
  final int wisataId;

  const TombolFavorit({super.key, required this.wisataId});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavoritStore.ids,
      builder: (context, ids, _) {
        final aktif = ids.contains(wisataId);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FavoritStore.toggle(wisataId),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: aktif
                      ? AppColor.kuning
                      : AppColor.putih.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  aktif ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: aktif ? AppColor.putih : AppColor.abu,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}