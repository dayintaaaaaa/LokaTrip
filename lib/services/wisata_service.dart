import 'package:supabase_flutter/supabase_flutter.dart';
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

class WisataService {
  final _db = Supabase.instance.client;

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

  // semua wisata yang sudah disetujui
  Future<List<Wisata>> getSemua({List<String>? kotaIn}) async {
    var q = _db.from('wisata').select(_select).eq('status_approve', 'Y');
    if (kotaIn != null) q = q.inFilter('kota', kotaIn);
    return _parse(await q
        .order('rata_rating', ascending: false)
        .order('jml_ulasan', ascending: false)
        .order('id_wisata'));
  }

  // destinasi terpopuler (rating, lalu jumlah ulasan)
  Future<List<Wisata>> getTerpopuler({int limit = 10, List<String>? kotaIn}) async {
    var q = _db.from('wisata').select(_select).eq('status_approve', 'Y');
    if (kotaIn != null) q = q.inFilter('kota', kotaIn);
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
    var q = _db
        .from('wisata')
        .select(_select)
        .eq('status_approve', 'Y')
        .inFilter('id_kategori', kategoriIds);
    if (kotaIn != null) q = q.inFilter('kota', kotaIn);
    final data = await q
        .order('rata_rating', ascending: false)
        .order('jml_ulasan', ascending: false)
        .order('id_wisata')
        .limit(limit);
    return _parse(data);
  }

  // wisata per kategori, kotaIn opsional (mis. ['Malang', 'Batu'])
  Future<List<Wisata>> getByKategori(int idKategori, {List<String>? kotaIn}) async {
    var q = _db
        .from('wisata')
        .select(_select)
        .eq('status_approve', 'Y')
        .eq('id_kategori', idKategori);
    if (kotaIn != null) q = q.inFilter('kota', kotaIn);
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
        .inFilter('id_wisata', ids);
    return _parse(data);
  }

  // daftar kategori untuk halaman Semua Kategori
  Future<List<Map<String, dynamic>>> getKategori() async {
    final data = await _db.from('kategori').select().order('id_kategori');
    return List<Map<String, dynamic>>.from(data);
  }
}