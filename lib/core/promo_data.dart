import 'package:flutter/material.dart';
import 'app_color.dart';
import 'format.dart';
import '../widgets/promo_card.dart';

// 125000 -> "Rp 125.000"
String rp(int n) => 'Rp ${formatAngka(n)}';

enum PromoTipe { destinasi, flash, tur }

class PromoItem {
  final String id;
  final PromoTipe tipe;
  final String kota; // Kota Malang / Kabupaten Malang / Kota Batu
  final String kategori; // Candi & Budaya / Waterpark / Taman Hiburan / Alam
  final String judul;
  final String lokasi;
  final Color warna; // warna placeholder gambar
  final int harga;
  final int hargaCoret;
  final String satuan; // "/orang"
  final String satuanJumlah; // "tiket", "orang", "boat"

  // kartu destinasi
  final String rating;
  final String ulasan;
  final String badgeUtama; // juga dipakai badge flash & tur
  final String badgeKedua;
  final String kategoriLokasi;
  final String chipInfo;
  final String labelHarga;
  final String teksTombol;
  final List<PromoFitur> fitur;

  // flash sale
  final int sisaTiket;
  final int persenTerjual;

  // tur
  final String kategoriTur;
  final String deskripsi;
  final Color badgeWarna;
  final Color badgeTeks;

  const PromoItem({
    required this.id,
    required this.tipe,
    required this.kota,
    required this.kategori,
    required this.judul,
    required this.lokasi,
    required this.warna,
    required this.harga,
    required this.hargaCoret,
    this.satuan = '/orang',
    this.satuanJumlah = 'tiket',
    this.rating = '',
    this.ulasan = '',
    this.badgeUtama = '',
    this.badgeKedua = '',
    this.kategoriLokasi = '',
    this.chipInfo = '',
    this.labelHarga = 'Mulai dari',
    this.teksTombol = 'Pilih Tiket',
    this.fitur = const [],
    this.sisaTiket = 0,
    this.persenTerjual = 0,
    this.kategoriTur = '',
    this.deskripsi = '',
    this.badgeWarna = AppColor.kuning,
    this.badgeTeks = AppColor.ungu,
  });
}

// TODO: ganti dengan data dari backend
const List<PromoItem> daftarPromo = [
  // ================== FLASH SALE ==================
  PromoItem(
    id: 'flash-malang-smart-arena',
    tipe: PromoTipe.flash,
    kota: 'Kabupaten Malang',
    kategori: 'Taman Hiburan',
    judul: 'Malang Smart Arena - Tiket Playground Indoor',
    lokasi: 'Karanglo, Singosari, Kabupaten Malang',
    warna: AppColor.biru,
    harga: 137500,
    hargaCoret: 250000,
    rating: '4.9',
    ulasan: '4.2k ulasan',
    badgeUtama: 'Diskon 45%',
    sisaTiket: 3,
    persenTerjual: 92,
  ),
  PromoItem(
    id: 'flash-candi-singosari',
    tipe: PromoTipe.flash,
    kota: 'Kabupaten Malang',
    kategori: 'Candi & Budaya',
    judul: 'Candi Singosari & Arca Dwarapala',
    lokasi: 'Singosari, Kabupaten Malang',
    warna: AppColor.ungu,
    harga: 60000,
    hargaCoret: 100000,
    rating: '4.9',
    ulasan: '6.8k ulasan',
    badgeUtama: 'Diskon 40%',
    sisaTiket: 6,
    persenTerjual: 85,
  ),

  // ================== DESTINASI SEDANG DISKON ==================
  PromoItem(
    id: 'museum-angkut',
    tipe: PromoTipe.destinasi,
    kota: 'Kota Batu',
    kategori: 'Candi & Budaya',
    judul: 'Museum Angkut Batu Tiket Reguler',
    lokasi: 'Kota Batu',
    kategoriLokasi: 'Museum & Rekreasi',
    warna: AppColor.biru,
    harga: 80000,
    hargaCoret: 125000,
    rating: '4.8',
    ulasan: '14.2k ulasan',
    badgeUtama: 'Diskon 35%',
    badgeKedua: 'Hemat Rp 45.000',
    chipInfo: 'Konfirmasi Instan',
    labelHarga: 'Mulai dari',
    teksTombol: 'Pesan Promo',
    fitur: [
      PromoFitur(Icons.confirmation_number_outlined, 'Bebas Antre Loket'),
      PromoFitur(Icons.local_drink_outlined, 'Free Welcome Drink'),
    ],
  ),
  PromoItem(
    id: 'candi-songgoriti',
    tipe: PromoTipe.destinasi,
    kota: 'Kota Batu',
    kategori: 'Candi & Budaya',
    judul: 'Candi Songgoriti & Pemandian Air Panas',
    lokasi: 'Songgokerto, Kota Batu',
    kategoriLokasi: 'Candi & Pemandian',
    warna: AppColor.kuning,
    harga: 150000,
    hargaCoret: 200000,
    rating: '4.8',
    ulasan: '9.1k ulasan',
    badgeUtama: 'Diskon 25%',
    badgeKedua: 'Hemat Rp 50.000',
    chipInfo: 'Tiket Elektronik',
    labelHarga: 'Mulai dari',
    teksTombol: 'Pesan Promo',
    fitur: [
      PromoFitur(Icons.headset_mic_outlined, 'Free Audio Guide'),
      PromoFitur(Icons.confirmation_number_outlined, 'Bebas Antre Loket'),
    ],
  ),
  PromoItem(
    id: 'jatim-park-3',
    tipe: PromoTipe.destinasi,
    kota: 'Kota Batu',
    kategori: 'Taman Hiburan',
    judul: 'Jatim Park 3: Dino Park & The Legend Stars',
    lokasi: 'Kota Batu',
    kategoriLokasi: 'Theme Park',
    warna: AppColor.ungu,
    harga: 115000,
    hargaCoret: 170000,
    satuan: '/tiket',
    rating: '4.7',
    ulasan: '9.8k ulasan',
    badgeUtama: 'Beli 2 Dapat 3',
    badgeKedua: 'Spesial Keluarga',
    chipInfo: 'Tiket Elektronik',
    labelHarga: 'Harga Promo Bundling',
    teksTombol: 'Pilih Tiket',
    fitur: [
      PromoFitur(Icons.attractions_outlined, 'Akses Terusan 2 Wahana'),
      PromoFitur(Icons.child_care_outlined, 'Anak <85cm Gratis'),
    ],
  ),
  PromoItem(
    id: 'bns',
    tipe: PromoTipe.destinasi,
    kota: 'Kota Batu',
    kategori: 'Taman Hiburan',
    judul: 'Batu Night Spectacular (BNS)',
    lokasi: 'Kota Batu',
    kategoriLokasi: 'Taman Malam',
    warna: AppColor.biru,
    harga: 75000,
    hargaCoret: 100000,
    satuan: '/tiket',
    rating: '4.6',
    ulasan: '7.4k ulasan',
    badgeUtama: 'Diskon 25%',
    badgeKedua: 'Hemat Rp 25.000',
    chipInfo: 'Tiket Elektronik',
    labelHarga: 'Mulai dari',
    teksTombol: 'Pilih Tiket',
    fitur: [
      PromoFitur(Icons.nightlife_outlined, 'Wahana Malam Hari'),
      PromoFitur(Icons.restaurant_outlined, 'Voucher Kuliner'),
    ],
  ),
  PromoItem(
    id: 'hawai-waterpark',
    tipe: PromoTipe.destinasi,
    kota: 'Kota Malang',
    kategori: 'Waterpark',
    judul: 'Hawai Waterpark Malang Day Pass',
    lokasi: 'Kota Malang',
    kategoriLokasi: 'Waterpark',
    warna: AppColor.kuning,
    harga: 140000,
    hargaCoret: 200000,
    rating: '4.7',
    ulasan: '5.3k ulasan',
    badgeUtama: 'Diskon 30%',
    badgeKedua: 'Hemat Rp 60.000',
    chipInfo: 'Konfirmasi Instan',
    labelHarga: 'Mulai dari',
    teksTombol: 'Pesan Promo',
    fitur: [
      PromoFitur(Icons.pool_outlined, 'Akses Semua Seluncuran'),
      PromoFitur(Icons.lock_outline, 'Free Loker 1 Hari'),
    ],
  ),
  PromoItem(
    id: 'sengkaling',
    tipe: PromoTipe.destinasi,
    kota: 'Kabupaten Malang',
    kategori: 'Waterpark',
    judul: 'Taman Rekreasi Sengkaling Tiket Masuk',
    lokasi: 'Dau, Kabupaten Malang',
    kategoriLokasi: 'Waterpark',
    warna: AppColor.biru,
    harga: 95000,
    hargaCoret: 130000,
    rating: '4.6',
    ulasan: '6.2k ulasan',
    badgeUtama: 'Diskon 27%',
    badgeKedua: 'Hemat Rp 35.000',
    chipInfo: 'Tiket Elektronik',
    labelHarga: 'Mulai dari',
    teksTombol: 'Pilih Tiket',
    fitur: [
      PromoFitur(Icons.pool_outlined, 'Akses Semua Kolam'),
      PromoFitur(Icons.child_care_outlined, 'Anak <90cm Gratis'),
    ],
  ),
  PromoItem(
    id: 'coban-rondo',
    tipe: PromoTipe.destinasi,
    kota: 'Kabupaten Malang',
    kategori: 'Alam',
    judul: 'Coban Rondo Tiket Masuk & Wisata Alam Pujon',
    lokasi: 'Pujon, Kabupaten Malang',
    kategoriLokasi: 'Air Terjun',
    warna: AppColor.kuning,
    harga: 180000,
    hargaCoret: 240000,
    rating: '4.9',
    ulasan: '21.4k ulasan',
    badgeUtama: 'Diskon 25%',
    badgeKedua: 'Hemat Rp 60.000',
    chipInfo: 'Tukar Langsung',
    labelHarga: 'Mulai dari',
    teksTombol: 'Pilih Tiket',
    fitur: [
      PromoFitur(Icons.pets_outlined, 'Safari Journey & 9 Animal Shows'),
      PromoFitur(Icons.water_outlined, 'Free Safari Water Park'),
    ],
  ),
  PromoItem(
    id: 'pantai-ngliyep',
    tipe: PromoTipe.destinasi,
    kota: 'Kabupaten Malang',
    kategori: 'Alam',
    judul: 'Pantai Ngliyep Tiket Masuk & Wisata Pantai Selatan',
    lokasi: 'Donomulyo, Kabupaten Malang',
    kategoriLokasi: 'Wisata Pantai',
    warna: AppColor.biru,
    harga: 550000,
    hargaCoret: 650000,
    rating: '4.8',
    ulasan: '1.8k ulasan',
    badgeUtama: 'Diskon 15%',
    badgeKedua: 'Hemat Rp 100.000',
    chipInfo: 'Konfirmasi Instan',
    labelHarga: 'Mulai dari',
    teksTombol: 'Pesan Promo',
    fitur: [
      PromoFitur(Icons.directions_boat_outlined, 'Speedboat PP'),
      PromoFitur(Icons.scuba_diving_outlined, 'Alat Snorkeling'),
    ],
  ),

  // ================== PROMO TUR & PETUALANGAN ==================
  PromoItem(
    id: 'tur-bromo',
    tipe: PromoTipe.tur,
    kota: 'Kabupaten Malang',
    kategori: 'Alam',
    judul: 'Open Trip Bromo Midnight Sunrise',
    lokasi: 'Meeting Point Poncokusumo, Kabupaten Malang',
    warna: AppColor.ungu,
    harga: 300000,
    hargaCoret: 400000,
    satuan: '/orang',
    satuanJumlah: 'orang',
    badgeUtama: '-25%',
    kategoriTur: 'OPEN TRIP TERLARIS',
    deskripsi: 'Jeep 4x4, Kawah Bromo, Pasir Berbisik &...',
    badgeWarna: AppColor.kuning,
    badgeTeks: AppColor.ungu,
  ),
  PromoItem(
    id: 'tur-batu-city',
    tipe: PromoTipe.tur,
    kota: 'Kota Batu',
    kategori: 'Alam',
    judul: 'Batu City Tour (Museum Angkut, BNS & Petik Apel)',
    lokasi: 'Kota Batu',
    warna: AppColor.biru,
    harga: 675000,
    hargaCoret: 750000,
    satuan: '/orang',
    satuanJumlah: 'orang',
    badgeUtama: 'Hemat 75rb',
    kategoriTur: 'PAKET 1 BOAT (6 ORANG)',
    deskripsi: 'Termasuk guide, snack kelapa muda...',
    badgeWarna: AppColor.biru,
    badgeTeks: AppColor.putih,
  ),
];
