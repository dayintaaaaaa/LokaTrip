class Wisata {
  final int id;
  final String nama;
  final String lokasi;
  final int harga;
  final int? hargaAsli; // harga sebelum diskon (null = tidak ada diskon)
  final double? rating;
  final int? jumlahUlasan;
  final String? tipe; // contoh: 'Instant Pass', 'Open Trip'
  final int? sisaTiket;
  final bool bisaRefund;
  final String? gambar; // path asset, null = tampil placeholder

  const Wisata({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.harga,
    this.hargaAsli,
    this.rating,
    this.jumlahUlasan,
    this.tipe,
    this.sisaTiket,
    this.bisaRefund = false,
    this.gambar,
  });

  // persen diskon dihitung otomatis dari dua harga
  int get diskonPersen {
    final asli = hargaAsli;
    if (asli == null || asli <= harga) return 0;
    return (((asli - harga) / asli) * 100).round();
  }
}