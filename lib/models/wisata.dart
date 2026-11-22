class HargaPengunjung {
  final int idDetailPaket;
  final String tipe;
  final int harga;

  const HargaPengunjung({required this.idDetailPaket, required this.tipe, required this.harga});
}

class WisataPaket {
  final int id;
  final String nama;
  final String tipe;
  final List<HargaPengunjung> hargaPengunjung;

  const WisataPaket({required this.id, required this.nama, required this.tipe, required this.hargaPengunjung});
}

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
  final List<String> kategoriLain; // kategori tambahan tempat wisata ini tampil
  final String? jenis; // pengelompokan chip di halaman kategori
  final String? subkategori; // contoh: 'Petualangan Offroad & Pantai'
  final String? deskripsi; // kalimat singkat di bawah judul kartu
  final int? sisaTiket;
  final int? terjualPersen; // untuk progress bar flash sale (0-100)
  final int? poin; // contoh: 450 -> "+450 Poin"
  final bool bisaRefund;
  final String? gambar; // path asset, null = tampil placeholder
  final String? ulasan; // cuplikan ulasan pendek
  final String? labelGambar; // label kecil di atas gambar
  final String? termasuk; // contoh: 'Termasuk Tiket Masuk & Sarapan'
  final String? satuanHarga; // contoh: '/orang', '/malam'
  final List<String> fitur; // chip kecil, contoh: ['Bisa Reschedule']
  final String? bonus; // contoh: 'Bonus Cashback 10% Poin Loka'
  final List<WisataPaket> paketTiket;

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
    this.kategoriLain = const [],
    this.jenis,
    this.subkategori,
    this.deskripsi,
    this.sisaTiket,
    this.terjualPersen,
    this.poin,
    this.bisaRefund = false,
    this.gambar,
    this.ulasan,
    this.labelGambar,
    this.termasuk,
    this.satuanHarga,
    this.fitur = const [],
    this.bonus,
    this.paketTiket = const [],
  });

  factory Wisata.fromApiJson(Map<String, dynamic> json) {
    final category = json['kategori'];
    final packs = json['paket_wisata'];
    final photos = json['foto_wisata'];
    final parsedPackages = <WisataPaket>[];
    final adultPrices = <int>[];
    final prices = <int>[];
    if (packs is List) {
      for (final pack in packs.whereType<Map<String, dynamic>>()) {
        final packagePrices = <HargaPengunjung>[];
        final details = pack['detail_paket'];
        if (details is List) {
          for (final detail in details.whereType<Map<String, dynamic>>()) {
            final price = detail['harga'];
            final detailId = detail['id_detail_paket'];
            final type = detail['tipe_pengunjung'];
            if (price is num && detailId is num && type is String) {
              packagePrices.add(HargaPengunjung(
                idDetailPaket: detailId.toInt(),
                tipe: type,
                harga: price.toInt(),
              ));
              if (price > 0) prices.add(price.toInt());
              if (type == 'dewasa' && price > 0) adultPrices.add(price.toInt());
            }
          }
        }
        final packageId = pack['id_paket'];
        final packageName = pack['nama_paket'];
        final packageType = pack['tipe_paket'];
        if (packageId is num && packageName is String && packageType is String) {
          parsedPackages.add(WisataPaket(
            id: packageId.toInt(),
            nama: packageName,
            tipe: packageType,
            hargaPengunjung: packagePrices,
          ));
        }
      }
    }
    final photoRows = photos is List
        ? photos.whereType<Map<String, dynamic>>().toList()
        : const <Map<String, dynamic>>[];
    photoRows.sort((a, b) => (a['urutan'] as num? ?? 0).compareTo(b['urutan'] as num? ?? 0));
    final location = json['lokasi'] as String? ?? '';
    final city = json['kota'] as String?;

    return Wisata(
      id: (json['id_wisata'] as num?)?.toInt() ?? 0,
      nama: json['nama_wisata'] as String? ?? 'Wisata',
      lokasi: location,
      kota: city,
      harga: adultPrices.isNotEmpty
          ? adultPrices.reduce((a, b) => a < b ? a : b)
          : prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b),
      rating: (json['rata_rating'] as num?)?.toDouble(),
      jumlahUlasan: (json['jml_ulasan'] as num?)?.toInt(),
      kategori: category is Map<String, dynamic> ? category['nama_kategori'] as String? : null,
      jenis: json['jenis'] as String?,
      subkategori: json['subkategori'] as String?,
      deskripsi: json['deskripsi'] as String?,
      gambar: photoRows.isEmpty ? null : photoRows.first['url_foto'] as String?,
      paketTiket: parsedPackages,
    );
  }

  // persen diskon dihitung otomatis dari dua harga
  int get diskonPersen {
    final asli = hargaAsli;
    if (asli == null || asli <= harga) return 0;
    return (((asli - harga) / asli) * 100).round();
  }
}
