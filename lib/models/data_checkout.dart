import 'data_pemesanan.dart';

// Perhitungan harga di halaman checkout dan pembayaran.
class RincianHarga {
  final DataPemesanan pesanan;

  const RincianHarga({required this.pesanan});

  // Biaya layanan aplikasi per pesanan.
  static const int biayaLayananTetap = 20000;

  int get tiketDewasa => pesanan.dewasa * pesanan.hargaDewasa;
  int get tiketAnak => pesanan.anak * pesanan.hargaAnak;
  int get subtotalTiket => tiketDewasa + tiketAnak;

  int get biayaLayanan => biayaLayananTetap;
  bool get careExtra => false;
  int get biayaCare => 0;
  int get diskon => 0;

  int get total => subtotalTiket + biayaLayanan;
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
