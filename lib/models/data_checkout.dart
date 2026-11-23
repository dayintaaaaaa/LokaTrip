import 'data_pemesanan.dart';

<<<<<<< HEAD
class RincianHarga {
  final DataPemesanan pesanan;
  final bool careExtra;
=======
// Perhitungan harga di halaman checkout dan pembayaran.
// Total = harga tiket + biaya layanan aplikasi, sama dengan hitungan fungsi
// buat_pemesanan di Supabase (tanpa kupon, tanpa Care Extra).
class RincianHarga {
  final DataPemesanan pesanan;
>>>>>>> 2cc143eaec4226f7464f6bfe3044a0c8686df5b1

  const RincianHarga({required this.pesanan});

<<<<<<< HEAD
  const RincianHarga({required this.pesanan, this.careExtra = false});
=======
  // Biaya layanan aplikasi per pesanan.
  // HARUS SAMA dengan v_biaya_layanan di fungsi buat_pemesanan (Supabase).
  static const int biayaLayananTetap = 20000;
>>>>>>> 2cc143eaec4226f7464f6bfe3044a0c8686df5b1

  int get tiketDewasa => pesanan.dewasa * pesanan.hargaDewasa;
  int get tiketAnak => pesanan.anak * pesanan.hargaAnak;
  int get subtotalTiket => tiketDewasa + tiketAnak;
<<<<<<< HEAD
  int get biayaCare => careExtra ? pesanan.tiket * hargaCareExtra : 0;

  int get total => subtotalTiket + biayaCare;
=======
  int get biayaLayanan => biayaLayananTetap;

  // Fitur Care Extra dan kupon sudah dihapus. Getter di bawah dipertahankan
  // supaya widget lama yang masih membacanya tetap bisa dikompilasi.
  bool get careExtra => false;
  int get biayaCare => 0;
  int get diskon => 0;

  int get total => subtotalTiket + biayaLayanan;
>>>>>>> 2cc143eaec4226f7464f6bfe3044a0c8686df5b1
}

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