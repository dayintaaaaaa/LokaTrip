import 'package:flutter/material.dart';
import 'app_color.dart';
import 'format.dart';

enum JenisKupon { nominal, persen }

class KuponPromo {
  final String kode;
  final String judul; // "Diskon Rp 50.000"
  final String catatan; // "Min. trf 300rb"
  final JenisKupon jenis;
  final int nilai; // nominal rupiah, atau persen
  final int? maksPotongan; // untuk persen
  final int minTransaksi;
  final String? badge; // "Instan", "Sisa 8 Kuota"
  final Color badgeWarna;
  final IconData icon;
  final String syarat; // "Wisata Candi & Tur Budaya"
  final IconData syaratIcon;
  final String aksi; // "S&K Berlaku", "Hingga 31 Des"

  const KuponPromo({
    required this.kode,
    required this.judul,
    this.catatan = '',
    required this.jenis,
    required this.nilai,
    this.maksPotongan,
    this.minTransaksi = 0,
    this.badge,
    this.badgeWarna = AppColor.kuning,
    required this.icon,
    required this.syarat,
    required this.syaratIcon,
    this.aksi = 'S&K Berlaku',
  });

  bool layak(int subtotal) => subtotal >= minTransaksi;

  int hitung(int subtotal) {
    if (!layak(subtotal)) return 0;
    if (jenis == JenisKupon.persen) {
      var p = subtotal * nilai ~/ 100;
      if (maksPotongan != null && p > maksPotongan!) p = maksPotongan!;
      return p;
    }
    return nilai > subtotal ? subtotal : nilai;
  }
}

// hasil dari halaman Pilih Kupon (kupon null = kupon dihapus)
class KuponHasil {
  final KuponPromo? kupon;
  const KuponHasil(this.kupon);
}

// TODO: ganti dengan data dari backend (tabel coupons / promo_codes)
const List<KuponPromo> daftarKupon = [
  KuponPromo(
    kode: 'LOKATRIPHEMAT',
    judul: 'Diskon Rp 50.000',
    catatan: 'Min. trf 300rb',
    jenis: JenisKupon.nominal,
    nilai: 50000,
    minTransaksi: 300000,
    icon: Icons.verified_outlined,
    syarat: 'Wisata Candi & Tur Budaya',
    syaratIcon: Icons.temple_buddhist_outlined,
  ),
  KuponPromo(
    kode: 'BOROBUDURSUNRISE',
    judul: 'Diskon 20%',
    catatan: 's/d Rp 100rb',
    jenis: JenisKupon.persen,
    nilai: 20,
    maksPotongan: 100000,
    badge: 'Sisa 8 Kuota',
    icon: Icons.wb_sunny_outlined,
    syarat: 'Khusus Borobudur & VW Safari',
    syaratIcon: Icons.directions_car_outlined,
  ),
  KuponPromo(
    kode: 'QRISSERU',
    judul: 'Cashback Rp 25.000',
    catatan: 'Semua Destinasi',
    jenis: JenisKupon.nominal,
    nilai: 25000,
    badge: 'Instan',
    icon: Icons.qr_code_2,
    syarat: 'Metode QRIS & E-Wallet',
    syaratIcon: Icons.account_balance_wallet_outlined,
    aksi: 'Hingga 31 Des',
  ),
  KuponPromo(
    kode: 'LIBURANSERU',
    judul: 'Diskon Rp 75.000',
    catatan: 'Min. trf 500rb',
    jenis: JenisKupon.nominal,
    nilai: 75000,
    minTransaksi: 500000,
    badge: 'Populer',
    badgeWarna: AppColor.ungu,
    icon: Icons.landscape_outlined,
    syarat: 'Semua Wisata Alam & Budaya',
    syaratIcon: Icons.park_outlined,
  ),
  KuponPromo(
    kode: 'BCATRAVEL',
    judul: 'Diskon Tambahan 10%',
    catatan: 'Maks. 50rb',
    jenis: JenisKupon.persen,
    nilai: 10,
    maksPotongan: 50000,
    badge: 'Partner',
    badgeWarna: AppColor.ungu,
    icon: Icons.account_balance_outlined,
    syarat: 'Khusus Virtual Account BCA',
    syaratIcon: Icons.credit_card_outlined,
    aksi: 'Promo Bank',
  ),
  KuponPromo(
    kode: 'FLASHSALE50',
    judul: 'Potongan Rp 30.000',
    catatan: 'Tanpa Min. Trf',
    jenis: JenisKupon.nominal,
    nilai: 30000,
    badge: 'Tinggal 2 jam',
    icon: Icons.timer_outlined,
    syarat: 'Khusus Tur & Aktivitas Hari Ini',
    syaratIcon: Icons.bolt,
    aksi: 'Flash Sale',
  ),
];

// cari kupon dari kode yang diketik (dipakai di Checkout & halaman Pilih Kupon)
({KuponPromo? kupon, String? error}) cariKupon(String input, int subtotal) {
  final kode = input.trim().toUpperCase();
  if (kode.isEmpty) return (kupon: null, error: 'Masukkan kode kupon dulu');
  final i = daftarKupon.indexWhere((k) => k.kode == kode);
  if (i == -1) return (kupon: null, error: 'Kode kupon tidak ditemukan');
  final k = daftarKupon[i];
  if (!k.layak(subtotal)) {
    return (
      kupon: null,
      error: 'Minimal transaksi Rp ${formatAngka(k.minTransaksi)}',
    );
  }
  return (kupon: k, error: null);
}

// data pesanan yang dibawa dari Checkout sampai E-Tiket
class DataCheckout {
  final String judul; // "Borobudur Sunrise Tour"
  final String paket; // "Paket Wisata Domestik • Jalur Candi Utama"
  final String lokasi; // "Magelang, Jawa Tengah"
  final DateTime tanggal;
  final String waktu; // "04:30 WIB (Pagi)"
  final String tamu; // "2 Dewasa"
  final String jenisTiket; // "Tiket Reguler Akses"
  final String titikKumpul;
  final Color warnaGambar;
  final int subtotal;
  final KuponPromo? kupon;

  const DataCheckout({
    required this.judul,
    required this.paket,
    required this.lokasi,
    required this.tanggal,
    required this.waktu,
    required this.tamu,
    required this.jenisTiket,
    required this.titikKumpul,
    required this.subtotal,
    this.warnaGambar = AppColor.ungu,
    this.kupon,
  });

  int get potongan => kupon?.hitung(subtotal) ?? 0;
  int get total => subtotal - potongan;

  DataCheckout denganKupon(KuponPromo? k) => DataCheckout(
        judul: judul,
        paket: paket,
        lokasi: lokasi,
        tanggal: tanggal,
        waktu: waktu,
        tamu: tamu,
        jenisTiket: jenisTiket,
        titikKumpul: titikKumpul,
        warnaGambar: warnaGambar,
        subtotal: subtotal,
        kupon: k,
      );
}

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String tglPendek(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';
String tglPanjang(DateTime d) => '${_hari[d.weekday - 1]}, ${tglPendek(d)}';

String formatWaktu(Duration d) {
  String dua(int n) => n.toString().padLeft(2, '0');
  return '${dua(d.inMinutes)}:${dua(d.inSeconds % 60)}';
}