import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/lokasi_malang_raya.dart';
import '../models/detail_wisata.dart';
import '../models/wisata.dart';

// id kategori sesuai tabel kategori di Supabase
class KategoriId {
  static const atraksi = 1; // Atraksi & Rekreasi
  static const candiBudaya = 2; // Candi & Budaya
  static const waterpark = 3; // Waterpark & Kolam
  static const tur = 4; // Tur & Open Trip
  static const playground = 5; // Playground
  static const spa = 6; // Spa & Pijat
  static const alam = 7; // Alam & Outbound
}

class DataUlasanWisata {
  final double? rating;
  final int jumlah;
  final List<UlasanDetail> ulasan;

  const DataUlasanWisata({
    required this.rating,
    required this.jumlah,
    required this.ulasan,
  });
}

class WisataService {
  final _db = Supabase.instance.client;

  static List<String> _lokasiValid(List<String>? requested) {
    if (requested == null) return LokasiMalangRaya.kota;
    return requested
        .where((kota) => LokasiMalangRaya.kota.contains(kota))
        .toList(growable: false);
  }

  // data relasi ikut diambil dalam satu query
  static const _select = '''
    *,
    kategori(nama_kategori),
    foto_wisata(url_foto, urutan),
    paket_wisata(id_paket, nama_paket, tipe_paket, deskripsi,
                 detail_paket(tipe_pengunjung, harga))
  ''';

  List<Wisata> _parse(dynamic data) =>
      (data as List).map((e) => Wisata.fromMap(e)).toList();

  static const _bulanUlasan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String _waktuUlasan(dynamic value) {
    final raw = value?.toString() ?? '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final tanggal = parsed.isUtc
        ? parsed.toUtc().add(const Duration(hours: 7))
        : parsed;
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final hariUlasan = DateTime.utc(tanggal.year, tanggal.month, tanggal.day);
    final hariIni = DateTime.utc(now.year, now.month, now.day);
    final hari = hariIni.difference(hariUlasan).inDays;
    if (hari <= 0) return 'Hari ini';
    if (hari == 1) return '1 hari lalu';
    if (hari < 7) return '$hari hari lalu';
    if (hari < 30) return '${(hari / 7).floor()} minggu lalu';
    if (hari < 365) return '${(hari / 30).floor()} bulan lalu';
    return '${tanggal.day} ${_bulanUlasan[tanggal.month - 1]} ${tanggal.year}';
  }

  static UlasanDetail _parseUlasan(Map<String, dynamic> row) {
    final nama = (row['nama'] as String?)?.trim();
    final username = (row['username'] as String?)?.trim();
    final komentar = (row['komentar'] as String?)?.trim() ?? '';
    return UlasanDetail(
      id: (row['id_ulasan'] as num?)?.toInt(),
      nama: nama?.isNotEmpty == true
          ? nama!
          : username?.isNotEmpty == true
          ? username!
          : 'Wisatawan LokaTrip',
      asal: 'Pembeli terverifikasi',
      waktu: _waktuUlasan(row['tanggal_ulasan']),
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      teks: komentar.isNotEmpty
          ? komentar
          : 'Memberi rating tanpa komentar.',
      fotoProfil: (row['foto_profil'] as String?)?.trim(),
    );
  }

  /// RPC mengembalikan agregat dan identitas tampilan publik pengulas.
  Future<DataUlasanWisata> ambilUlasanWisata(int idWisata) async {
    final raw = await _db.rpc(
      'ulasan_wisata_detail',
      params: {'p_id_wisata': idWisata},
    );
    final data = Map<String, dynamic>.from(raw as Map);
    final rows = data['ulasan'] as List? ?? const [];
    final ulasan = rows
        .map((value) => _parseUlasan(Map<String, dynamic>.from(value as Map)))
        .toList(growable: false);

    final jumlah = (data['jml_ulasan'] as num?)?.toInt() ?? 0;
    final nilaiRating = (data['rata_rating'] as num?)?.toDouble();
    return DataUlasanWisata(
      rating: jumlah == 0 ? null : nilaiRating,
      jumlah: jumlah,
      ulasan: ulasan,
    );
  }

  Future<List<UlasanDetail>> ambilSemuaUlasanWisata(int idWisata) async {
    final raw = await _db.rpc(
      'ulasan_wisata_semua',
      params: {'p_id_wisata': idWisata},
    );
    if (raw is! List) return const [];
    return raw
        .map((value) => _parseUlasan(Map<String, dynamic>.from(value as Map)))
        .toList(growable: false);
  }

  // semua wisata yang sudah disetujui
  Future<List<Wisata>> getSemua({List<String>? kotaIn}) async {
    final lokasi = _lokasiValid(kotaIn);
    final q = _db
        .from('wisata')
        .select(_select)
        .eq('status_approve', 'Y')
        .eq('aktif_katalog', true)
        .inFilter('kota', lokasi);
    return _parse(await q
        .order('rata_rating', ascending: false)
        .order('jml_ulasan', ascending: false)
        .order('id_wisata'));
  }

  // destinasi terpopuler (rating, lalu jumlah ulasan)
  Future<List<Wisata>> getTerpopuler({int limit = 10, List<String>? kotaIn}) async {
    final lokasi = _lokasiValid(kotaIn);
    final q = _db
        .from('wisata')
        .select(_select)
        .eq('status_approve', 'Y')
        .eq('aktif_katalog', true)
        .inFilter('kota', lokasi);
    return _parse(await q
        .order('rata_rating', ascending: false)
        .order('jml_ulasan', ascending: false)
        .order('id_wisata')
        .limit(limit));
  }

  // kurasi trip spesial akhir pekan (rekomendasi: Tur & Open Trip, Alam & Outbound, Waterpark)
  Future<List<Wisata>> getTripAkhirPekan({
    List<int> kategoriIds = const [
      KategoriId.tur,
      KategoriId.alam,
      KategoriId.waterpark,
    ],
    int limit = 6,
    List<String>? kotaIn,
  }) async {
    final lokasi = _lokasiValid(kotaIn);
    final q = _db
        .from('wisata')
        .select(_select)
        .eq('status_approve', 'Y')
        .eq('aktif_katalog', true)
        .inFilter('kota', lokasi)
        .inFilter('id_kategori', kategoriIds);
    final data = await q
        .order('rata_rating', ascending: false)
        .order('jml_ulasan', ascending: false)
        .order('id_wisata')
        .limit(limit);
    return _parse(data);
  }

  // Wisata per kategori; lokasi selalu dibatasi ke Malang Raya.
  Future<List<Wisata>> getByKategori(int idKategori, {List<String>? kotaIn}) async {
    final lokasi = _lokasiValid(kotaIn);
    final q = _db
        .from('wisata')
        .select(_select)
        .eq('status_approve', 'Y')
        .eq('aktif_katalog', true)
        .inFilter('kota', lokasi)
        .eq('id_kategori', idKategori);
    return _parse(await q
        .order('rata_rating', ascending: false)
        .order('id_wisata'));
  }

  // pencarian nama wisata atau kota
  Future<List<Wisata>> cari(String keyword) async {
    final data = await _db
        .from('wisata')
        .select(_select)
        .eq('status_approve', 'Y')
        .eq('aktif_katalog', true)
        .inFilter('kota', LokasiMalangRaya.kota)
        .or('nama_wisata.ilike.%$keyword%,kota.ilike.%$keyword%')
        .order('rata_rating', ascending: false)
        .order('id_wisata');
    return _parse(data);
  }

  // satu wisata lengkap (untuk halaman Destination Detail)
  Future<Wisata> getDetail(int idWisata) async {
    final data = await _db
        .from('wisata')
        .select(_select)
        .eq('id_wisata', idWisata)
        .eq('status_approve', 'Y')
        .eq('aktif_katalog', true)
        .inFilter('kota', LokasiMalangRaya.kota)
        .single();
    return Wisata.fromMap(data);
  }

  // beberapa wisata sekaligus berdasarkan id (dipakai hasil AI)
  Future<List<Wisata>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final data = await _db
        .from('wisata')
        .select(_select)
        .eq('status_approve', 'Y')
        .eq('aktif_katalog', true)
        .inFilter('kota', LokasiMalangRaya.kota)
        .inFilter('id_wisata', ids);
    return _parse(data);
  }

  // daftar kategori untuk halaman Semua Kategori
  Future<List<Map<String, dynamic>>> getKategori() async {
    final data = await _db.from('kategori').select().order('id_kategori');
    return List<Map<String, dynamic>>.from(data);
  }
}
