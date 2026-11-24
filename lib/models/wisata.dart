import 'paket_wisata.dart';

class HargaPengunjung {
  final int idDetailPaket;
  final String tipe;
  final int harga;

  const HargaPengunjung({
    required this.idDetailPaket,
    required this.tipe,
    required this.harga,
  });
}

class WisataPaket {
  final int id;
  final String nama;
  final String tipe;
  final List<HargaPengunjung> hargaPengunjung;

  const WisataPaket({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.hargaPengunjung,
  });
}

class Wisata {
  final int id;
  final String nama;
  final String lokasi;
  final String? kota;
  final int harga;
  final int? hargaAsli;
  final double? rating;
  final int? jumlahUlasan;
  final String? tipe;
  final String? kategori;
  final List<String> kategoriLain;
  final String? jenis;
  final String? subkategori;
  final String? deskripsi;
  final int? sisaTiket;
  final int? terjualPersen;
  final int? poin;
  final bool bisaRefund;
  final String? gambar;
  final String? ulasan;
  final String? labelGambar;
  final String? termasuk;
  final String? satuanHarga;
  final List<String> fitur;
  final int? idKategori;
  final List<String> fotoList;
  final List<PaketWisata> paket;
  final String? bonus;
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
    this.idKategori,
    this.fotoList = const [],
    this.paket = const [],
    this.bonus,
    this.paketTiket = const [],
  });

  // Membaca data dari WisataService.
  factory Wisata.fromMap(Map<String, dynamic> m) {
    final fotoRaw =
        ((m['foto_wisata'] ?? []) as List).cast<Map<String, dynamic>>()
          ..sort((a, b) => (a['urutan'] ?? 0).compareTo(b['urutan'] ?? 0));

    final fotos = fotoRaw.map((foto) => foto['url_foto'] as String).toList();

    final paket = ((m['paket_wisata'] ?? []) as List)
        .map((item) => PaketWisata.fromMap(item))
        .toList();

    final semuaHarga = paket
        .expand((item) => item.detail)
        .map((detail) => detail.harga)
        .where((harga) => harga > 0);

    final ulasanCount = (m['jml_ulasan'] ?? 0) as int;
    final ratingValue = (m['rata_rating'] ?? 0).toDouble();
    final idKategori = m['id_kategori'] as int?;

    String? tipeOtomatis = m['tipe'] ?? m['subkategori'] ?? m['jenis'];

    if (tipeOtomatis == null || tipeOtomatis.isEmpty) {
      if (idKategori == 4) {
        tipeOtomatis = 'Open Trip';
      } else if (idKategori == 7) {
        tipeOtomatis = 'Wisata Alam';
      } else if (idKategori == 3) {
        tipeOtomatis = 'Waterpark';
      } else if (idKategori == 1) {
        tipeOtomatis = 'Atraksi';
      } else if (idKategori == 6) {
        tipeOtomatis = 'Wellness & Relax';
      } else {
        tipeOtomatis = m['kategori']?['nama_kategori'];
      }
    }

    String? labelGambarOtomatis = m['label_gambar'];

    if (labelGambarOtomatis == null || labelGambarOtomatis.isEmpty) {
      if (idKategori == 4) {
        labelGambarOtomatis = 'Day Trip';
      } else if (idKategori == 7) {
        final namaLower = (m['nama_wisata'] ?? '').toString().toLowerCase();

        labelGambarOtomatis = namaLower.contains('glamping')
            ? 'Staycation'
            : 'Outdoor';
      } else if (idKategori == 3) {
        labelGambarOtomatis = 'Tiket Masuk';
      }
    }

    String? termasukOtomatis = m['termasuk'];

    if (termasukOtomatis == null || termasukOtomatis.isEmpty) {
      if (paket.isNotEmpty &&
          paket.first.deskripsi != null &&
          paket.first.deskripsi!.isNotEmpty) {
        termasukOtomatis = paket.first.deskripsi;
      } else if (idKategori == 4) {
        termasukOtomatis = 'Termasuk Pemandu & Tiket Wisata';
      } else {
        termasukOtomatis = 'Termasuk Tiket Masuk Resmi';
      }
    }

    final namaLower = (m['nama_wisata'] ?? '').toString().toLowerCase();

    final satuanHargaOtomatis =
        m['satuan_harga'] ??
        (idKategori == 7 && namaLower.contains('glamping')
            ? '/malam'
            : (idKategori == 3 ? '/tiket' : '/orang'));

    final ulasanKutipan =
        m['ulasan'] ??
        (m['deskripsi'] != null && (m['deskripsi'] as String).isNotEmpty
            ? m['deskripsi']
            : null);

    return Wisata(
      id: m['id_wisata'],
      nama: m['nama_wisata'] ?? '',
      lokasi: m['lokasi'] ?? '',
      kota: m['kota'],
      harga: semuaHarga.isEmpty
          ? 0
          : semuaHarga.reduce((a, b) => a < b ? a : b),
      hargaAsli: (m['harga_asli'] as num?)?.toInt(),
      rating: ulasanCount > 0 ? ratingValue : null,
      jumlahUlasan: ulasanCount > 0 ? ulasanCount : null,
      kategori: m['kategori']?['nama_kategori'],
      idKategori: idKategori,
      jenis: m['jenis'],
      subkategori: m['subkategori'],
      deskripsi: m['deskripsi'],
      gambar: fotos.isNotEmpty ? fotos.first : null,
      fotoList: fotos,
      paket: paket,
      tipe: tipeOtomatis,
      labelGambar: labelGambarOtomatis,
      termasuk: termasukOtomatis,
      satuanHarga: satuanHargaOtomatis,
      ulasan: ulasanKutipan,
    );
  }

  // Membaca data katalog dari UserApi.
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
              packagePrices.add(
                HargaPengunjung(
                  idDetailPaket: detailId.toInt(),
                  tipe: type,
                  harga: price.toInt(),
                ),
              );

              if (price > 0) {
                prices.add(price.toInt());
              }

              if (type == 'dewasa' && price > 0) {
                adultPrices.add(price.toInt());
              }
            }
          }
        }

        final packageId = pack['id_paket'];
        final packageName = pack['nama_paket'];
        final packageType = pack['tipe_paket'];

        if (packageId is num &&
            packageName is String &&
            packageType is String) {
          parsedPackages.add(
            WisataPaket(
              id: packageId.toInt(),
              nama: packageName,
              tipe: packageType,
              hargaPengunjung: packagePrices,
            ),
          );
        }
      }
    }

    final photoRows = photos is List
        ? photos.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    photoRows.sort(
      (a, b) => (a['urutan'] as num? ?? 0).compareTo(b['urutan'] as num? ?? 0),
    );

    final location = json['lokasi'] as String? ?? '';
    final city = json['kota'] as String?;
    final ulasanCount = (json['jml_ulasan'] as num?)?.toInt() ?? 0;

    final hargaKatalog = adultPrices.isNotEmpty
        ? adultPrices.reduce((a, b) => a < b ? a : b)
        : prices.isEmpty
        ? 0
        : prices.reduce((a, b) => a < b ? a : b);

    return Wisata(
      id: (json['id_wisata'] as num?)?.toInt() ?? 0,
      nama: json['nama_wisata'] as String? ?? 'Wisata',
      lokasi: location,
      kota: city,
      harga: hargaKatalog,
      hargaAsli: (json['harga_asli'] as num?)?.toInt(),
      rating: ulasanCount > 0
          ? (json['rata_rating'] as num?)?.toDouble()
          : null,
      jumlahUlasan: ulasanCount > 0 ? ulasanCount : null,
      kategori: category is Map<String, dynamic>
          ? category['nama_kategori'] as String?
          : null,
      jenis: json['jenis'] as String?,
      subkategori: json['subkategori'] as String?,
      deskripsi: json['deskripsi'] as String?,
      gambar: photoRows.isEmpty ? null : photoRows.first['url_foto'] as String?,
      fotoList: photoRows
          .map((foto) => foto['url_foto'])
          .whereType<String>()
          .toList(),
      idKategori: (json['id_kategori'] as num?)?.toInt(),
      paketTiket: parsedPackages,
    );
  }

  // Persentase diskon dihitung otomatis dari dua harga.
  int get diskonPersen {
    final asli = hargaAsli;

    if (asli == null || asli <= harga) {
      return 0;
    }

    return (((asli - harga) / asli) * 100).round();
  }
}
