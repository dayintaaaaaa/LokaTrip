import 'package:flutter/foundation.dart';
import 'api_client.dart';

// Menyimpan id wisata yang difavoritkan.
// Sementara di memori (hilang saat app ditutup).
class FavoritStore {
  static final ValueNotifier<Set<int>> ids = ValueNotifier<Set<int>>({});

  static bool apakahFavorit(int id) => ids.value.contains(id);

  static Future<void> toggle(int id, String token) async {
    final baru = Set<int>.from(ids.value);
    if (baru.remove(id)) {
      await UserApi.removeWishlist(token, id);
    } else {
      await UserApi.addWishlist(token, id);
      baru.add(id);
    }
    ids.value = baru;
  }
}
