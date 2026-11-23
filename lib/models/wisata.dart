import 'paket_wisata.dart';

class Wisata {
  final int id;
  final String nama;
  final String lokasi;
  final String? kota; // dipakai untuk filter lokasi, contoh: 'Bali'
  final int harga;
  final double? rating;
  final int? jumlahUlasan;
  final String? tipe; // contoh: 'Instant Pass', 'Konfirmasi Instan'
  final String? kategori; // harus sama dengan nama di Kategori.daftar
  final List<String> kategoriLain; // kategori tambahan tempat wisata ini tampil
  final String? jenis; // pengelompokan chip di halaman kategori
  final String? subkategori; // contoh: 'Petualangan Offroad & Pantai'
  final String? deskripsi; // kalimat singkat di bawah judul kartu
  final int? sisaTiket;
  final bool bisaRefund;
  final String? gambar; // URL foto utama (atau path asset untuk dummy), null = placeholder
  final String? ulasan; // cuplikan ulasan pendek
  final String? labelGambar; // label kecil di atas gambar
  final String? termasuk; // contoh: 'Termasuk Tiket Masuk & Sarapan'
  final String? satuanHarga; // contoh: '/orang', '/malam'
  final List<String> fitur; // chip kecil, contoh: ['Bisa Reschedule']
  // field baru di dalam class Wisata
  final int? idKategori;
  final List<String> fotoList;
  final List<PaketWisata> paket;

  const Wisata({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.harga,
    this.kota,
    this.rating,
    this.jumlahUlasan,
    this.tipe,
    this.kategori,
    this.kategoriLain = const [],
    this.jenis,
    this.subkategori,
    this.deskripsi,
    this.sisaTiket,
    this.bisaRefund = false,
    this.gambar,
    this.ulasan,
    this.labelGambar,
    this.termasuk,
    this.satuanHarga,
    this.fitur = const [],
    // di constructor, tambahkan:
    this.idKategori,
    this.fotoList = const [],
    this.paket = const [],
  });


  // factory baru di dalam class Wisata
  factory Wisata.fromMap(Map<String, dynamic> m) {
    final fotoRaw = ((m['foto_wisata'] ?? []) as List)
        .cast<Map<String, dynamic>>()
      ..sort((a, b) => (a['urutan'] ?? 0).compareTo(b['urutan'] ?? 0));
    final fotos = fotoRaw.map((f) => f['url_foto'] as String).toList();

    final paket = ((m['paket_wisata'] ?? []) as List)
        .map((p) => PaketWisata.fromMap(p))
        .toList();

    // harga terendah dari semua paket (balita/gratis tidak dihitung)
    final semuaHarga =
        paket.expand((p) => p.detail).map((d) => d.harga).where((h) => h > 0);

    final ulasan = (m['jml_ulasan'] ?? 0) as int;
    final rating = (m['rata_rating'] ?? 0).toDouble();

    return Wisata(
      id: m['id_wisata'],
      nama: m['nama_wisata'] ?? '',
      lokasi: m['lokasi'] ?? '',
      kota: m['kota'],
      harga: semuaHarga.isEmpty ? 0 : semuaHarga.reduce((a, b) => a < b ? a : b),
      rating: ulasan > 0 ? rating : null,        // belum ada ulasan -> rating disembunyikan
      jumlahUlasan: ulasan > 0 ? ulasan : null,
      kategori: m['kategori']?['nama_kategori'],
      idKategori: m['id_kategori'],
      jenis: m['jenis'],
      subkategori: m['subkategori'],
      deskripsi: m['deskripsi'],
      gambar: fotos.isNotEmpty ? fotos.first : null,
      fotoList: fotos,
      paket: paket,
      satuanHarga: '/orang',
    );
  }
}