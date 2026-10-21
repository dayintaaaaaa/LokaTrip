class Wisata {
  final int id;
  final String nama;
  final String lokasi;
  final String? kota; // dipakai untuk filter lokasi, contoh: 'Bali'
  final int harga;
  final int? hargaAsli; // harga sebelum diskon (null = tidak ada diskon)
  final double? rating;
  final int? jumlahUlasan;
  final String? tipe; // contoh: 'Instant Pass', 'Konfirmasi Instan'
  final String? kategori; // harus sama dengan nama di Kategori.daftar
  final String? subkategori; // contoh: 'Petualangan Offroad & Pantai'
  final int? sisaTiket;
  final int? terjualPersen; // untuk progress bar flash sale (0-100)
  final int? poin; // contoh: 450 -> "+450 Poin"
  final bool bisaRefund;
  final String? gambar; // path asset, null = tampil placeholder
  final String? ulasan; // cuplikan ulasan pendek
  final String? labelGambar; // label kecil di atas gambar
  final String? termasuk; // contoh: 'Termasuk Tiket Masuk & Sarapan'
  final String? satuanHarga; // contoh: '/orang', '/malam'

  const Wisata({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.harga,
    this.kota,
    this.hargaAsli,
    this.rating,
    this.jumlahUlasan,
    this.tipe,
    this.kategori,
    this.subkategori,
    this.sisaTiket,
    this.terjualPersen,
    this.poin,
    this.bisaRefund = false,
    this.gambar,
    this.ulasan,
    this.labelGambar,
    this.termasuk,
    this.satuanHarga,
  });

  // persen diskon dihitung otomatis dari dua harga
  int get diskonPersen {
    final asli = hargaAsli;
    if (asli == null || asli <= harga) return 0;
    return (((asli - harga) / asli) * 100).round();
  }
}