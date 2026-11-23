import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pesanan_saya.dart';

// Membaca pesanan milik wisatawan yang sedang login.
// Yang terbaca otomatis hanya milik sendiri karena dibatasi policy RLS
// (pesanan_milik_sendiri dan policy tabel turunannya).
class PesananService {
  final SupabaseClient _db = Supabase.instance.client;

  static const _select = '''
    *,
    kuota_harian(
      tanggal,
      paket_wisata(
        id_paket, nama_paket, tipe_paket,
        wisata(id_wisata, nama_wisata, kota, foto_wisata(url_foto, urutan))
      )
    ),
    detail_pemesanan(tipe_pengunjung, jumlah, subtotal_harga_tiket),
    pembayaran(metode_bayar, status_bayar, waktu_bayar),
    e_tiket(id_tiket, kode_qr, status_tiket)
  ''';

  /// Semua pesanan, yang terbaru di atas.
  Future<List<PesananSaya>> daftarSaya() async {
    try {
      final data = await _db
          .from('pemesanan')
          .select(_select)
          .order('dibuat_pada', ascending: false);
      return (data as List)
          .map((e) => PesananSaya.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Muat daftar pesanan gagal: $e');
      rethrow;
    }
  }

  /// Satu pesanan berdasarkan kode pesan (untuk halaman detail / e-tiket).
  Future<PesananSaya> detail(String kodePesan) async {
    try {
      final data = await _db
          .from('pemesanan')
          .select(_select)
          .eq('kode_pesan', kodePesan)
          .single();
      return PesananSaya.fromMap(data);
    } catch (e) {
      debugPrint('Muat detail pesanan gagal: $e');
      rethrow;
    }
  }
}