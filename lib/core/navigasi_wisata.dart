// core/navigasi_wisata.dart
import 'package:flutter/material.dart';
import '../models/wisata.dart';
import '../features/user/detail_wisata_screens.dart';

void bukaDetailWisata(BuildContext context, Wisata w) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => DetailWisataScreens(wisata: w)),
  );
}