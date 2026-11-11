import 'detail_wisata.dart';

// Hasil pilihan di halaman "Atur Jadwal & Pengunjung".
// Dibawa terus ke halaman berikutnya (data pemesan, pembayaran, dst).
class DataPemesanan {
  final DetailWisata detail;
  final GrupTiket grup; // WNI / WNA
  final PaketTiket paket;
  final DateTime tanggal;
  final int dewasa;
  final int anak;
  final int bayi;
  final int hargaDewasa; // harga per orang pada tanggal terpilih
  final int hargaAnak;

  const DataPemesanan({
    required this.detail,
    required this.grup,
    required this.paket,
    required this.tanggal,
    required this.dewasa,
    required this.anak,
    required this.bayi,
    required this.hargaDewasa,
    required this.hargaAnak,
  });

  // bayi gratis dan tidak memakai kursi, jadi tidak dihitung tiket
  int get tiket => dewasa + anak;
  int get total => dewasa * hargaDewasa + anak * hargaAnak;
}