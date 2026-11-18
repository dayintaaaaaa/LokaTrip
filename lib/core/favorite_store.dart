import 'package:flutter/foundation.dart';

// Menyimpan id wisata yang difavoritkan.
// Sementara di memori (hilang saat app ditutup).
class FavoritStore {
  static final ValueNotifier<Set<int>> ids = ValueNotifier<Set<int>>({});

  static bool apakahFavorit(int id) => ids.value.contains(id);

  static void toggle(int id) {
    final baru = Set<int>.from(ids.value);
    if (!baru.remove(id)) baru.add(id);
    ids.value = baru; // objek baru supaya pendengar tahu ada perubahan
  }
}