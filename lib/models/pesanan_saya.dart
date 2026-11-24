// Satu pesanan milik wisatawan yang sedang login, dibaca dari Supabase
// (pemesanan + kuota_harian + paket_wisata + wisata + detail_pemesanan
// + pembayaran + e_tiket).

enum StatusPesananSaya { menungguBayar, aktif, selesai, kadaluarsa }

extension StatusPesananSayaLabel on StatusPesananSaya {
  String get label => switch (this) {
        StatusPesananSaya.menungguBayar => 'Menunggu Pembayaran',
        StatusPesananSaya.aktif => 'Aktif',
        StatusPesananSaya.selesai => 'Selesai',
        StatusPesananSaya.kadaluarsa => 'Kedaluwarsa',
      };
}

class PesananSaya {
  final int idPemesanan;
  final String kodePesan;
  final String statusDb; // menunggu_pembayaran | aktif | kadaluarsa
  final int subtotal;
  final int biayaLayanan;
  final int totalBayar;
  final DateTime dibuatPada;
  final DateTime? tanggalKunjungan;
  final int? idWisata;
  final String namaWisata;
  final String? kota;
  final String? foto;
  final String? namaPaket;
  final String? tipePaket; // reguler | standar
  final int dewasa;
  final int anak;
  final int bayi;
  final String? metodeBayar; // qris | virtual_account | dompet_digital | kartu_kredit
  final DateTime? waktuBayar;
  final List<String> kodeTiket;

  const PesananSaya({
    required this.idPemesanan,
    required this.kodePesan,
    required this.statusDb,
    required this.subtotal,
    required this.biayaLayanan,
    required this.totalBayar,
    required this.dibuatPada,
    required this.namaWisata,
    this.tanggalKunjungan,
    this.idWisata,
    this.kota,
    this.foto,
    this.namaPaket,
    this.tipePaket,
    this.dewasa = 0,
    this.anak = 0,
    this.bayi = 0,
    this.metodeBayar,
    this.waktuBayar,
    this.kodeTiket = const [],
  });

  // batas waktu bayar, sama dengan aturan di fungsi simulasi_bayar
  static const batasBayar = Duration(minutes: 15);

  // Sisa waktu bayar, null kalau pesanan tidak sedang menunggu pembayaran.
  Duration? get sisaWaktuBayar {
    if (statusDb != 'menunggu_pembayaran') return null;
    final sisa = batasBayar - DateTime.now().difference(dibuatPada);
    return sisa.isNegative ? Duration.zero : sisa;
  }

  // Status yang ditampilkan di aplikasi. Pesanan yang belum dibayar dan sudah
  // lewat batas waktu dianggap kedaluwarsa walau database belum memperbaruinya.
  // Pesanan aktif yang tanggal kunjungannya sudah lewat dianggap selesai.
  StatusPesananSaya get status {
    if (statusDb == 'menunggu_pembayaran') {
      return sisaWaktuBayar == Duration.zero
          ? StatusPesananSaya.kadaluarsa
          : StatusPesananSaya.menungguBayar;
    }
    if (statusDb == 'aktif') {
      final t = tanggalKunjungan;
      final sekarang = DateTime.now();
      final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
      if (t != null && DateTime(t.year, t.month, t.day).isBefore(hariIni)) {
        return StatusPesananSaya.selesai;
      }
      return StatusPesananSaya.aktif;
    }
    return StatusPesananSaya.kadaluarsa;
  }

  // bayi tidak memakai kursi, jadi tidak dihitung tiket
  int get jumlahTiket => dewasa + anak;

  String get ringkasanTamu {
    final bagian = <String>[
      if (dewasa > 0) '$dewasa Dewasa',
      if (anak > 0) '$anak Anak',
      if (bayi > 0) '$bayi Bayi',
    ];
    return bagian.join(', ');
  }

  String? get labelMetode => switch (metodeBayar) {
        'qris' => 'QRIS',
        'virtual_account' => 'Virtual Account',
        'dompet_digital' => 'Dompet Digital',
        'kartu_kredit' => 'Kartu Kredit',
        _ => null,
      };

  // Relasi satu-ke-banyak datang sebagai List, satu-ke-satu sebagai Map.
  static List<Map<String, dynamic>> _daftar(dynamic v) {
    if (v is List) return v.whereType<Map<String, dynamic>>().toList();
    if (v is Map<String, dynamic>) return <Map<String, dynamic>>[v];
    return <Map<String, dynamic>>[];
  }

  factory PesananSaya.fromMap(Map<String, dynamic> m) {
    final kuota = m['kuota_harian'] as Map<String, dynamic>?;
    final paket = kuota?['paket_wisata'] as Map<String, dynamic>?;
    final wisata = paket?['wisata'] as Map<String, dynamic>?;

    final foto = _daftar(wisata?['foto_wisata'])
      ..sort((a, b) => ((a['urutan'] ?? 0) as int).compareTo((b['urutan'] ?? 0) as int));

    int jumlah(String tipe) => _daftar(m['detail_pemesanan'])
        .where((d) => d['tipe_pengunjung'] == tipe)
        .fold<int>(0, (a, d) => a + ((d['jumlah'] ?? 0) as int));

    // pakai pembayaran yang berhasil, kalau tidak ada pakai yang pertama
    final bayar = _daftar(m['pembayaran']);
    final lunas = bayar.where((b) => b['status_bayar'] == 'berhasil').toList();
    final b = lunas.isNotEmpty ? lunas.first : (bayar.isNotEmpty ? bayar.first : null);
    final waktuBayar = b?['waktu_bayar'] as String?;

    final tiket = _daftar(m['e_tiket'])
      ..sort((a, b) => ((a['id_tiket'] ?? 0) as int).compareTo((b['id_tiket'] ?? 0) as int));

    final tgl = kuota?['tanggal'] as String?;

    return PesananSaya(
      idPemesanan: m['id_pemesanan'] as int,
      kodePesan: m['kode_pesan'] as String,
      statusDb: m['status_pesan'] as String,
      subtotal: (m['subtotal'] ?? 0) as int,
      biayaLayanan: (m['biaya_layanan'] ?? 0) as int,
      totalBayar: (m['total_bayar'] ?? 0) as int,
      dibuatPada: DateTime.parse(m['dibuat_pada'] as String).toLocal(),
      tanggalKunjungan: tgl == null ? null : DateTime.parse(tgl),
      idWisata: wisata?['id_wisata'] as int?,
      namaWisata: (wisata?['nama_wisata'] ?? 'Wisata tidak tersedia') as String,
      kota: wisata?['kota'] as String?,
      foto: foto.isEmpty ? null : foto.first['url_foto'] as String?,
      namaPaket: paket?['nama_paket'] as String?,
      tipePaket: paket?['tipe_paket'] as String?,
      dewasa: jumlah('dewasa'),
      anak: jumlah('anak_anak'),
      bayi: jumlah('balita'),
      metodeBayar: b?['metode_bayar'] as String?,
      waktuBayar: waktuBayar == null ? null : DateTime.parse(waktuBayar).toLocal(),
      kodeTiket: tiket.map((t) => t['kode_qr'] as String).toList(),
    );
  }
}