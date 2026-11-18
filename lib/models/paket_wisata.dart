class DetailPaket {
  final String tipePengunjung; // dewasa | anak_anak | balita
  final int harga;
  const DetailPaket({required this.tipePengunjung, required this.harga});

  factory DetailPaket.fromMap(Map<String, dynamic> m) => DetailPaket(
        tipePengunjung: m['tipe_pengunjung'] ?? '',
        harga: m['harga'] ?? 0,
      );
}

class PaketWisata {
  final int idPaket;
  final String namaPaket;
  final String tipePaket; // reguler | standar
  final String? deskripsi;
  final List<DetailPaket> detail;
  const PaketWisata({
    required this.idPaket,
    required this.namaPaket,
    required this.tipePaket,
    this.deskripsi,
    this.detail = const [],
  });

  factory PaketWisata.fromMap(Map<String, dynamic> m) => PaketWisata(
        idPaket: m['id_paket'],
        namaPaket: m['nama_paket'] ?? '',
        tipePaket: m['tipe_paket'] ?? '',
        deskripsi: m['deskripsi'],
        detail: ((m['detail_paket'] ?? []) as List)
            .map((d) => DetailPaket.fromMap(d))
            .toList(),
      );
}