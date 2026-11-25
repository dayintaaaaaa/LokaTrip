import 'package:flutter/foundation.dart';
import 'api_client.dart';

class FavoritStore {
  static final ValueNotifier<Set<int>> ids = ValueNotifier<Set<int>>({});
  static Future<void>? _pemuatan;
  static bool _sudahMuat = false;

  static bool apakahFavorit(int id) => ids.value.contains(id);

  static Future<void> muat(String token, {bool paksa = false}) async {
    if (_sudahMuat && !paksa) return;
    final aktif = _pemuatan;
    if (aktif != null) {
      await aktif;
      return;
    }
    final tugas = _ambil(token);
    _pemuatan = tugas;
    try {
      await tugas;
    } finally {
      _pemuatan = null;
    }
  }

  static Future<void> _ambil(String token) async {
    final rows = await UserApi.wishlist(token);
    ids.value = rows
        .map((row) => (row['id_wisata'] as num?)?.toInt())
        .whereType<int>()
        .toSet();
    _sudahMuat = true;
  }

  static Future<void> toggle(int id, String token) async {
    await muat(token);
    final baru = Set<int>.from(ids.value);
    if (baru.remove(id)) {
      await UserApi.removeWishlist(token, id);
    } else {
      await UserApi.addWishlist(token, id);
      baru.add(id);
    }
    ids.value = baru;
  }

  static void bersihkan() {
    ids.value = <int>{};
    _sudahMuat = false;
    _pemuatan = null;
  }
}
