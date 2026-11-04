import 'package:flutter/material.dart';

// Isi banner promo di bagian atas halaman kategori.
class PromoKategori {
  final String label; // contoh: 'EKSKLUSIF LOKATRIP'
  final String judul;
  final String deskripsi;
  final String? periode; // contoh: 'Hingga 31 Mar', tampil di kanan label
  final String? kode; // kode kupon
  final String? awalanKode; // contoh: 'Kode Kupon:' (kode tampil di kotak putih)
  final String? catatan; // contoh: 'S&K Berlaku' di kanan baris kode
  final String? tombol; // tombol putih di kanan: 'Klaim' atau 'Salin'
  final IconData? ikon; // ikon hias bulat di kanan (kalau tidak ada tombol)

  const PromoKategori({
    required this.label,
    required this.judul,
    required this.deskripsi,
    this.periode,
    this.kode,
    this.awalanKode,
    this.catatan,
    this.tombol,
    this.ikon,
  });
}