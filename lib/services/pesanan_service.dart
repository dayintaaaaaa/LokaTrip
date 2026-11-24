<<<<<<< HEAD

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/format_rupiah.dart';
import '../core/pesanan_model.dart';

class PesananGagal implements Exception {
  final String pesan;
  PesananGagal(this.pesan);

  @override
  String toString() => pesan;
}

/// Ambil pesanan milik user yang login.
/// Pembatasan per akun dilakukan RLS (pemesanan_milik_sendiri).
class PesananService {
  final SupabaseClient _db = Supabase.instance.client;

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static const _namaTipe = {
    'dewasa': 'Dewasa',
    'anak_anak': 'Anak',
    'balita': 'Bayi',
  };

  static String _tgl(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  // Relasi bisa datang sebagai Map atau List.
  static Map<String, dynamic>? _satu(dynamic v) {
    if (v is List) {
      return v.isEmpty
          ? null
          : Map<String, dynamic>.from(v.first as Map);
    }

    if (v is Map) {
      return Map<String, dynamic>.from(v);
    }

    return null;
  }

  // Normalisasi relasi agar Map maupun List bisa diproses.
  static List<Map<String, dynamic>> _daftar(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (v is Map) {
      return [Map<String, dynamic>.from(v)];
    }

    return [];
  }

  static String? _jam(dynamic v) =>
      v is String && v.length >= 5 ? v.substring(0, 5) : null;

  static String _metode(Map<String, dynamic> b) {
    final p = b['penyedia'] as String?;

    if (p != null && p.trim().isNotEmpty) return p;

    return switch (b['metode_bayar']) {
      'qris' => 'QRIS',
      'virtual_account' => 'Virtual Account',
      'dompet_digital' => 'Dompet Digital',
      'kartu_kredit' => 'Kartu Kredit',
      _ => '-',
    };
  }

  Future<List<Pesanan>> ambilSemua() async {
    final List<dynamic> data;

    try {
      data = await _db
          .from('pemesanan')
          .select(
            'id_pemesanan, kode_pesan, tgl_pesan, total_bayar, status_pesan, '
            'dibuat_pada, '
            'kuota_harian(tanggal, paket_wisata(nama_paket, tipe_paket, '
            'wisata(nama_wisata, lokasi, kota, jenis, jam_buka, jam_tutup))), '
            'pembayaran(metode_bayar, penyedia, status_bayar), '
            'detail_pemesanan(tipe_pengunjung, jumlah)',
          )
          .order('dibuat_pada', ascending: false);
    } on PostgrestException catch (e) {
      debugPrint('Muat pesanan gagal: ${e.code} ${e.message}');
      throw PesananGagal('Gagal memuat pesanan: ${e.message}');
    } catch (e) {
      debugPrint('Muat pesanan error: $e');
      throw PesananGagal(
        'Gagal memuat pesanan, periksa koneksi internetmu',
      );
    }

    // Ulasan diambil terpisah supaya kegagalannya tidak merusak daftar pesanan.
    final ulasan = <int, Map<String, dynamic>>{};

    try {
      final ids = [
        for (final m in data) m['id_pemesanan'] as int
      ];

      if (ids.isNotEmpty) {
        final u = await _db
            .from('ulasan')
            .select('id_pemesanan, rating, komentar')
            .inFilter('id_pemesanan', ids);

        for (final r in u) {
          ulasan[r['id_pemesanan'] as int] =
              Map<String, dynamic>.from(r);
        }
      }
    } catch (e) {
      debugPrint('Muat ulasan dilewati: $e');
    }

    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final hasil = <Pesanan>[];

    for (final item in data) {
      final m = Map<String, dynamic>.from(item as Map);

      final statusDb = m['status_pesan'] as String;
      final dibuat =
          DateTime.parse(m['dibuat_pada'] as String).toLocal();

      if (statusDb == 'kadaluarsa') continue;

      if (statusDb == 'menunggu_pembayaran' &&
          sekarang.difference(dibuat).inMinutes >= 15) {
        continue;
      }

      final kuota = _satu(m['kuota_harian']);
      final paket = _satu(kuota?['paket_wisata']);
      final wisata = _satu(paket?['wisata']);

      final tglKunjungan = kuota?['tanggal'] is String
          ? DateTime.parse(kuota!['tanggal'] as String)
          : null;

      final lewat =
          tglKunjungan != null && tglKunjungan.isBefore(hariIni);

      final StatusPesanan status;
      final String labelStatus;

      if (statusDb == 'menunggu_pembayaran') {
        status = StatusPesanan.terkonfirmasi;
        labelStatus = 'Menunggu Pembayaran';
      } else if (lewat) {
        status = StatusPesanan.selesai;
        labelStatus = 'Selesai';
      } else {
        status = StatusPesanan.siapDigunakan;
        labelStatus = 'Siap Digunakan';
      }

      final tipePaket =
          '${paket?['tipe_paket'] ?? ''}'.toLowerCase();

      final tur = tipePaket.contains('tur');

      // Peserta
      final jml = <String, int>{};

      for (final d in _daftar(m['detail_pemesanan'])) {
        final t = d['tipe_pengunjung'] as String;
        jml[t] = (jml[t] ?? 0) + (d['jumlah'] as int);
      }

      final peserta = [
        for (final e in _namaTipe.entries)
          if ((jml[e.key] ?? 0) > 0)
            '${jml[e.key]} ${e.value}',
      ].join(', ');

      // Pembayaran: pilih yang berhasil, kalau belum ada ambil yang pertama.
      final bayar = _daftar(m['pembayaran']);

      final b = bayar.firstWhere(
        (x) => x['status_bayar'] == 'berhasil',
        orElse: () =>
            bayar.isNotEmpty ? bayar.first : <String, dynamic>{},
      );

      final buka = _jam(wisata?['jam_buka']);
      final tutup = _jam(wisata?['jam_tutup']);

      final idPemesanan = m['id_pemesanan'] as int;
      final u = ulasan[idPemesanan];

      hasil.add(
        Pesanan(
          id: m['kode_pesan'] as String,
          idPemesanan: idPemesanan,
          tglBeli: _tgl(
            DateTime.parse(m['tgl_pesan'] as String),
          ),
          dibuat: dibuat,
          status: status,
          labelStatus: labelStatus,
          kategori: tur
              ? KategoriPesanan.tur
              : KategoriPesanan.tiketWisata,
          labelFoto:
              (wisata?['jenis'] as String?) ?? (tur ? 'Tur' : 'Tiket'),
          judul: (wisata?['nama_wisata'] as String?) ?? 'Wisata',
          lokasi: (wisata?['lokasi'] as String?) ??
              (wisata?['kota'] as String?) ??
              '-',
          chips: [
            (paket?['nama_paket'] as String?) ?? 'Paket',
            peserta.isEmpty ? '-' : peserta,
          ],
          labelJadwal: tur ? 'Jadwal Tur' : 'Jadwal Kunjungan',
          jadwal: tglKunjungan == null ? '-' : _tgl(tglKunjungan),
          jam: (buka != null && tutup != null)
              ? '$buka - $tutup'
              : null,
          labelTotal: statusDb == 'menunggu_pembayaran'
              ? 'Total Tagihan'
              : 'Total Bayar',
          total: formatRupiah(m['total_bayar'] as int),
          metode: _metode(b),
          rating: (u?['rating'] as num?)?.toDouble(),
          ulasan: u?['komentar'] as String?,
        ),
      );
    }

    return hasil;
  }
}
=======
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
>>>>>>> daa95c622d6c50a0444812146fd6c39ce86954ea
