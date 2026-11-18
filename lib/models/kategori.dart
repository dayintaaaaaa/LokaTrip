import 'package:flutter/material.dart';

class Kategori {
  final String nama; // nama pendek di grid (juga kunci pencocokan data)
  final IconData icon;
  final String? judul; // judul halaman kalau beda dari nama
  final String? subjudul; // keterangan di Direktori Kategori
  final String? label; // label kecil di kartu "Kategori Terpopuler"
  final bool ramahAnak;

  const Kategori(
    this.nama,
    this.icon, {
    this.judul,
    this.subjudul,
    this.label,
    this.ramahAnak = false,
  });

  String get judulHalaman => judul ?? nama;

  static const daftar = [
    Kategori(
      'Atraksi & Rekreasi',
      Icons.attractions_outlined,
      subjudul: 'Theme park & pertunjukan',
      label: 'Theme Park & Zoo',
      ramahAnak: true,
    ),
    Kategori(
      'Candi & Budaya',
      Icons.temple_buddhist_outlined,
      subjudul: 'Heritage & kearifan lokal',
      label: 'UNESCO & Heritage',
    ),
    Kategori(
      'Waterpark & Kolam',
      Icons.waves,
      subjudul: 'Rekreasi & wellness air',
      label: 'Seru Basah-basahan',
      ramahAnak: true,
    ),
    Kategori(
      'Tur & Open Trip',
      Icons.hiking,
      subjudul: 'Paket tur & petualangan',
      label: 'Best Seller Trip',
    ),
    Kategori(
      'Playground',
      Icons.sports_esports_outlined,
      judul: 'Playground & Edukasi',
      subjudul: 'Taman bermain & edukasi',
      ramahAnak: true,
    ),
    Kategori(
      'Spa & Pijat',
      Icons.spa_outlined,
      judul: 'Spa & Relaksasi',
      subjudul: 'Relaksasi & wellness',
    ),
    Kategori(
      'Alam & Outbound',
      Icons.landscape_outlined,
      judul: 'Alam & Petualangan',
      subjudul: 'Ekowisata & trekking',
      ramahAnak: true,
    ),
  ];

  // tile terakhir di grid
  static const semua = Kategori('Semua Kategori', Icons.grid_view_rounded);
}