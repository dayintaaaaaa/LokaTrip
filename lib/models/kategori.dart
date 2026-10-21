import 'package:flutter/material.dart';

class Kategori {
  final String nama;
  final IconData icon;

  const Kategori(this.nama, this.icon);

  static const daftar = [
    Kategori('Atraksi & Rekreasi', Icons.attractions_outlined),
    Kategori('Candi & Budaya', Icons.temple_buddhist_outlined),
    Kategori('Waterpark & Kolam', Icons.waves),
    Kategori('Tur & Open Trip', Icons.hiking),
    Kategori('Playground', Icons.sports_esports_outlined),
    Kategori('Spa & Pijat', Icons.spa_outlined),
    Kategori('Alam & Outbound', Icons.landscape_outlined),
  ];

  // tile terakhir di grid
  static const semua = Kategori('Semua Kategori', Icons.grid_view_rounded);
}