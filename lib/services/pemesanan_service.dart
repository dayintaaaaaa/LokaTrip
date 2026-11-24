import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PemesananGagal implements Exception {
  final String pesan;
  final String? teknis; // detail asli dari server, untuk debugging
  PemesananGagal(this.pesan, {this.teknis});
  @override
  String toString() => pesan;
}

class HasilPemesanan {
  final int idPemesanan;
  final String kodePesan;
  final int totalBayar;
  HasilPemesanan(this.idPemesanan, this.kodePesan, this.totalBayar);
}

// Hasil pembayaran: pesanan lunas dan e-tiket yang diterbitkan
// (satu kode per tiket dewasa/anak, bayi tidak).
class HasilBayar {
  final int idPemesanan;
  final String kodePesan;
  final int totalBayar;
  final List<String> kodeTiket;
  HasilBayar(this.idPemesanan, this.kodePesan, this.totalBayar, this.kodeTiket);
}

class PemesananService {
  final SupabaseClient _db = Supabase.instance.client;

  String _tgl(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Paket aktif satu wisata beserta harga per tipe pengunjung.
  Future<List<Map<String, dynamic>>> paketDanHarga(int idWisata) async {
    return await _db
        .from('paket_wisata')
        .select('id_paket, nama_paket, tipe_paket, deskripsi, '
            'detail_paket(id_detail_paket, tipe_pengunjung, harga)')
        .eq('id_wisata', idWisata)
        .eq('status_aktif', true);
  }

  /// Sisa kuota per tanggal untuk satu paket (kunci = tanggal).
  Future<Map<DateTime, int>> sisaKuota(
    int idPaket, {
    required DateTime dari,
    required DateTime sampai,
  }) async {
    final data = await _db
        .from('kuota_harian')
        .select('tanggal, kuota_total, kuota_terpakai')
        .eq('id_paket', idPaket)
        .gte('tanggal', _tgl(dari))
        .lte('tanggal', _tgl(sampai))
        .order('tanggal');
    return {
      for (final m in data)
        DateTime.parse(m['tanggal'] as String):
            (m['kuota_total'] as int) - (m['kuota_terpakai'] as int),
    };
  }

  /// jumlahPerTipe: {'dewasa': 2, 'anak_anak': 1, 'balita': 0}
  Future<HasilPemesanan> buat({
    required int idPaket,
    required DateTime tanggal,
    required Map<String, int> jumlahPerTipe,
  }) async {
    try {
      final res = await _db.rpc('buat_pemesanan', params: {
        'p_id_paket': idPaket,
        'p_tanggal': _tgl(tanggal),
        'p_items': [
          for (final e in jumlahPerTipe.entries)
            if (e.value > 0) {'tipe': e.key, 'jumlah': e.value},
        ],
      });
      final row = (res as List).first as Map<String, dynamic>;
      return HasilPemesanan(
        row['o_id_pemesanan'] as int,
        row['o_kode_pesan'] as String,
        row['o_total_bayar'] as int,
      );
    } on PostgrestException catch (e) {
      debugPrint('buat_pemesanan gagal: code=${e.code} '
          'msg=${e.message} details=${e.details}');
      throw PemesananGagal(_terjemah(e.message),
          teknis: '${e.code}: ${e.message}');
    } catch (e) {
      debugPrint('buat_pemesanan error: $e');
      throw PemesananGagal('Gagal membuat pesanan, periksa koneksi internetmu');
    }
  }

  /// Catat pembayaran dan terbitkan e-tiket.
  /// HANYA UNTUK PENGEMBANGAN: memanggil fungsi simulasi_bayar di Supabase.
  /// Ganti dengan status lunas dari webhook payment gateway sebelum dipakai
  /// sungguhan.
  /// metode: 'qris' | 'virtual_account' | 'dompet_digital' | 'kartu_kredit'
  Future<HasilBayar> bayarSimulasi({
    required String kodePesan,
    required String metode,
    String? penyedia,
  }) async {
    try {
      final res = await _db.rpc('simulasi_bayar', params: {
        'p_kode_pesan': kodePesan,
        'p_metode': metode,
        'p_penyedia': penyedia,
      });
      final row = (res as List).first as Map<String, dynamic>;
      return HasilBayar(
        row['o_id_pemesanan'] as int,
        row['o_kode_pesan'] as String,
        row['o_total_bayar'] as int,
        ((row['o_kode_tiket'] ?? []) as List).cast<String>(),
      );
    } on PostgrestException catch (e) {
      debugPrint('simulasi_bayar gagal: code=${e.code} '
          'msg=${e.message} details=${e.details}');
      throw PemesananGagal(_terjemah(e.message));
    } catch (e) {
      debugPrint('simulasi_bayar error: $e');
      throw PemesananGagal(
        'Gagal memproses pembayaran, periksa koneksi internetmu',
      );
    }
  }

  String _terjemah(String m) {
    if (m.contains('KUOTA_HABIS')) return 'Kuota untuk tanggal ini tidak cukup';
    if (m.contains('JADWAL_TIDAK_TERSEDIA')) return 'Tanggal ini belum tersedia';
    if (m.contains('TANGGAL_TIDAK_VALID')) return 'Tanggal tidak valid';
    if (m.contains('PAKET_TIDAK_TERSEDIA')) return 'Paket tidak tersedia';
    if (m.contains('TIKET_TIDAK_VALID')) return 'Pilih minimal 1 tiket yang valid';
    if (m.contains('BELUM_LOGIN')) return 'Silakan login dulu';
    if (m.contains('PESANAN_KADALUARSA')) {
      return 'Waktu pembayaran sudah habis, silakan ulangi pemesanan';
    }
    if (m.contains('PESANAN_TIDAK_DITEMUKAN')) return 'Pesanan tidak ditemukan';
    if (m.contains('PESANAN_TIDAK_VALID')) {
      return 'Pesanan ini tidak bisa dibayar lagi';
    }
    if (m.contains('METODE_TIDAK_VALID')) {
      return 'Metode pembayaran ini belum tersedia';
    }
    return 'Gagal memproses pesanan, coba lagi';
  }
}