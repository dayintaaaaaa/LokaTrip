import 'package:flutter/material.dart';
import '../core/app_color.dart';
import '../core/format_rupiah.dart';

// Satu kupon: potongan tetap (Rp) ATAU persen dengan batas maksimal.
class Kupon {
  final String kode;
  final int? potongan; // contoh: 50000
  final int? persen; // contoh: 25
  final int? maksPotongan; // batas atas untuk kupon persen
  final int minTransaksi; // syarat minimal subtotal tiket

  // tampilan di halaman "Promo & Kupon Spesial"
  final String judul; // "Diskon Rp 50.000" (kosong = dibuat otomatis)
  final String catatan; // "Min. trf 300rb"
  final String? badge; // "Instan", "Sisa 8 Kuota"
  final Color badgeWarna;
  final IconData icon;
  final String syarat; // "Wisata Candi & Tur Budaya"
  final IconData syaratIcon;
  final String aksi; // "S&K Berlaku", "Hingga 31 Des"

  const Kupon({
    required this.kode,
    this.potongan,
    this.persen,
    this.maksPotongan,
    this.minTransaksi = 0,
    this.judul = '',
    this.catatan = '',
    this.badge,
    this.badgeWarna = AppColor.kuning,
    this.icon = Icons.confirmation_number_outlined,
    this.syarat = 'Berlaku untuk semua wisata',
    this.syaratIcon = Icons.public,
    this.aksi = 'S&K Berlaku',
  });

  bool layak(int subtotal) => subtotal >= minTransaksi;

  String get judulTampil {
    if (judul.isNotEmpty) return judul;
    if (potongan != null) return 'Diskon ${formatRupiah(potongan!)}';
    return 'Diskon $persen%';
  }

  // besar diskon untuk subtotal tiket tertentu (0 kalau belum memenuhi syarat)
  int hitung(int subtotal) {
    if (!layak(subtotal)) return 0;
    var diskon = potongan ?? (persen == null ? 0 : subtotal * persen! ~/ 100);
    if (maksPotongan != null && diskon > maksPotongan!) diskon = maksPotongan!;
    return diskon > subtotal ? subtotal : diskon;
  }
}

// DUMMY: ganti dengan validasi kupon dari backend.
class KuponDummy {
  // kupon yang langsung terpasang saat halaman checkout dibuka (sesuai desain)
  static const bawaan = Kupon(
    kode: 'LOKATRIPHEMAT',
    potongan: 50000,
    minTransaksi: 300000,
    judul: 'Diskon Rp 50.000',
    catatan: 'Min. trf 300rb',
    icon: Icons.verified_outlined,
    syarat: 'Wisata Candi & Tur Budaya',
    syaratIcon: Icons.temple_buddhist_outlined,
  );

  static const daftar = [
    bawaan,
    Kupon(
      kode: 'BOROBUDURSUNRISE',
      persen: 20,
      maksPotongan: 100000,
      judul: 'Diskon 20%',
      catatan: 's/d Rp 100rb',
      badge: 'Sisa 8 Kuota',
      icon: Icons.wb_sunny_outlined,
      syarat: 'Khusus Borobudur & VW Safari',
      syaratIcon: Icons.directions_car_outlined,
    ),
    Kupon(
      kode: 'QRISSERU',
      potongan: 25000,
      judul: 'Cashback Rp 25.000',
      catatan: 'Semua Destinasi',
      badge: 'Instan',
      icon: Icons.qr_code_2,
      syarat: 'Metode QRIS & E-Wallet',
      syaratIcon: Icons.account_balance_wallet_outlined,
      aksi: 'Hingga 31 Des',
    ),
    Kupon(
      kode: 'LIBURANSERU',
      potongan: 75000,
      minTransaksi: 500000,
      judul: 'Diskon Rp 75.000',
      catatan: 'Min. trf 500rb',
      badge: 'Populer',
      badgeWarna: AppColor.ungu,
      icon: Icons.landscape_outlined,
      syarat: 'Semua Wisata Alam & Budaya',
      syaratIcon: Icons.park_outlined,
    ),
    Kupon(
      kode: 'BCATRAVEL',
      persen: 10,
      maksPotongan: 50000,
      judul: 'Diskon Tambahan 10%',
      catatan: 'Maks. 50rb',
      badge: 'Partner',
      badgeWarna: AppColor.ungu,
      icon: Icons.account_balance_outlined,
      syarat: 'Khusus Virtual Account BCA',
      syaratIcon: Icons.credit_card_outlined,
      aksi: 'Promo Bank',
    ),
    Kupon(
      kode: 'FLASHSALE50',
      potongan: 30000,
      judul: 'Potongan Rp 30.000',
      catatan: 'Tanpa Min. Trf',
      badge: 'Tinggal 2 jam',
      icon: Icons.timer_outlined,
      syarat: 'Khusus Tur & Aktivitas Hari Ini',
      syaratIcon: Icons.bolt,
      aksi: 'Flash Sale',
    ),
    Kupon(kode: 'KELANABUDAYA', persen: 25, maksPotongan: 75000),
  ];

  // null = kode tidak ditemukan
  static Kupon? cari(String kode) {
    final k = kode.trim().toUpperCase();
    for (final kupon in daftar) {
      if (kupon.kode == k) return kupon;
    }
    return null;
  }
}