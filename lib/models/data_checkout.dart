import 'data_pemesanan.dart';
import 'kupon_dummy.dart';

// Perhitungan harga di halaman checkout. Dihitung ulang setiap kali
// Care Extra atau kupon berubah, dan dipakai lagi di halaman pembayaran.
class RincianHarga {
  final DataPemesanan pesanan;
  final bool careExtra;
  final Kupon? kupon;

  static const int hargaCareExtra = 15000; // per tiket

  const RincianHarga({
    required this.pesanan,
    this.careExtra = false,
    this.kupon,
  });

  int get tiketDewasa => pesanan.dewasa * pesanan.hargaDewasa;
  int get tiketAnak => pesanan.anak * pesanan.hargaAnak;
  int get subtotalTiket => tiketDewasa + tiketAnak;

  // bayi tidak dihitung tiket, jadi tidak kena biaya Care Extra
  int get biayaCare => careExtra ? pesanan.tiket * hargaCareExtra : 0;

  // kupon dihitung dari harga tiket saja (tidak termasuk Care Extra)
  int get diskon => kupon == null ? 0 : kupon!.hitung(subtotalTiket);

  int get total => subtotalTiket + biayaCare - diskon;
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