enum KategoriPesanan { tiketWisata, tur }

enum StatusPesanan { siapDigunakan, terkonfirmasi, selesai }

class Pesanan {
  final String id; // kode_pesan
  final int idPemesanan;
  final String tglBeli;
  final DateTime? dibuat;
  final StatusPesanan status;
  final String labelStatus;
  final KategoriPesanan kategori;
  final String kategoriWisata;
  final String labelFoto;
  final String judul;
  final String lokasi;
  final List<String> chips; // [nama paket, peserta]
  final String labelJadwal;
  final String jadwal;
  final String? jam;
  final String labelTotal;
  final String total;
  final String? catatanTotal;
  final String metode;
  final bool bisaUlas;
  double? rating;
  String? ulasan;
  final int wisataId;
  final int orderId;

  Pesanan({
    required this.id,
    this.idPemesanan = 0,
    required this.tglBeli,
    this.dibuat,
    required this.status,
    required this.labelStatus,
    required this.kategori,
    required this.kategoriWisata,
    required this.labelFoto,
    required this.judul,
    required this.lokasi,
    required this.chips,
    required this.labelJadwal,
    required this.jadwal,
    this.jam,
    required this.labelTotal,
    required this.total,
    this.catatanTotal,
    required this.metode,
    this.bisaUlas = true,
    this.rating,
    this.ulasan,
    this.wisataId = 0,
    this.orderId = 0,
  });

  bool get aktif => status != StatusPesanan.selesai;
}
