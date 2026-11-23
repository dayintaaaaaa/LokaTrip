import 'data_pemesanan.dart';

// Perhitungan harga di halaman checkout dan pembayaran.
// Total = harga tiket + biaya layanan aplikasi, sama dengan hitungan fungsi
// buat_pemesanan di Supabase (tanpa kupon, tanpa Care Extra).
class RincianHarga {
  final DataPemesanan pesanan;

  const RincianHarga({required this.pesanan});

  // Biaya layanan aplikasi per pesanan.
  // HARUS SAMA dengan v_biaya_layanan di fungsi buat_pemesanan (Supabase).
  static const int biayaLayananTetap = 20000;

  int get tiketDewasa => pesanan.dewasa * pesanan.hargaDewasa;
  int get tiketAnak => pesanan.anak * pesanan.hargaAnak;
  int get subtotalTiket => tiketDewasa + tiketAnak;
  int get biayaLayanan => biayaLayananTetap;

  // Fitur Care Extra dan kupon sudah dihapus. Getter di bawah dipertahankan
  // supaya widget lama yang masih membacanya tetap bisa dikompilasi.
  bool get careExtra => false;
  int get biayaCare => 0;
  int get diskon => 0;

  int get total => subtotalTiket + biayaLayanan;
}

// Semua data yang dibawa ke halaman Pembayaran (langkah 2).
class DataCheckout {
  final DataPemesanan pesanan;
  final String nama;
  final String email;
  final String telepon;
  final RincianHarga rincian;

  const DataCheckout({
    required this.pesanan,
    required this.nama,
    required this.email,
    required this.telepon,
    required this.rincian,
  });
}