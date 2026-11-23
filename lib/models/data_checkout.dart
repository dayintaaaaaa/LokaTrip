import 'data_pemesanan.dart';

class RincianHarga {
  final DataPemesanan pesanan;
  final bool careExtra;

  static const int hargaCareExtra = 15000; // per tiket

  const RincianHarga({required this.pesanan, this.careExtra = false});

  int get tiketDewasa => pesanan.dewasa * pesanan.hargaDewasa;
  int get tiketAnak => pesanan.anak * pesanan.hargaAnak;
  int get subtotalTiket => tiketDewasa + tiketAnak;
  int get biayaCare => careExtra ? pesanan.tiket * hargaCareExtra : 0;

  int get total => subtotalTiket + biayaCare;
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