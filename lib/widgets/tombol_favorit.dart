import 'package:flutter/material.dart';
import '../core/app_color.dart';
import '../core/session_manager.dart';
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
          onTap: () async {
            final token = await SessionManager.currentUserToken();
            if (token == null || token.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Silakan login untuk menyimpan wishlist.')),
              );
              return;
            }
            try {
              await FavoritStore.toggle(wisataId, token);
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString())),
                );
              }
            }
          },
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: aktif ? AppColor.kuning : AppColor.putih,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  size: 15,
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
