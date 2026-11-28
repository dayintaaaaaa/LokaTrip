import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/format_rupiah.dart';
import '../core/pesanan_model.dart';
import '../models/pesanan_saya.dart';

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
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const _namaTipe = {
    'dewasa': 'Dewasa',
    'anak_anak': 'Anak',
    'balita': 'Bayi',
  };

  static String _tgl(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  // kuota_harian.tanggal is a PostgreSQL date, so preserve its calendar day
  // and compare date-only values against the WIB calendar day.
  static DateTime? _tanggalWib(dynamic value) {
    if (value is! String || value.length < 10) return null;
    final tanggal = DateTime.tryParse(value.substring(0, 10));
    if (tanggal == null) return null;
    return DateTime.utc(tanggal.year, tanggal.month, tanggal.day);
  }

  static DateTime _hariIniWib() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    return DateTime.utc(now.year, now.month, now.day);
  }

  // Relasi bisa datang sebagai Map atau List.
  static Map<String, dynamic>? _satu(dynamic v) {
    if (v is List) {
      return v.isEmpty ? null : Map<String, dynamic>.from(v.first as Map);
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

  Future<List<String>> ambilKategoriWisata() async {
    try {
      final data = await _db
          .from('kategori')
          .select('nama_kategori')
          .order('nama_kategori');
      return data
          .map((row) => '${row['nama_kategori'] ?? ''}'.trim())
          .where((nama) => nama.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Muat kategori wisata dilewati: $e');
      return [];
    }
  }

  Future<List<Pesanan>> ambilSemua() async {
    final List<dynamic> data;

    try {
      data = await _db
          .from('pemesanan')
          .select(
            'id_pemesanan, kode_pesan, tgl_pesan, total_bayar, status_pesan, '
            'dibuat_pada, '
            'kuota_harian(tanggal), '
            'pembayaran(metode_bayar, penyedia, status_bayar), '
            'detail_pemesanan(tipe_pengunjung, jumlah, '
            'detail_paket(id_detail_paket, paket_wisata(id_paket, nama_paket, tipe_paket, '
            'wisata(id_wisata, nama_wisata, lokasi, kota, jenis, jam_buka, jam_tutup, '
            'foto_wisata(url_foto, urutan), kategori(nama_kategori)))))',
          )
          .order('dibuat_pada', ascending: false);
    } on PostgrestException catch (e) {
      debugPrint('Muat pesanan gagal: ${e.code} ${e.message}');
      throw PesananGagal('Gagal memuat pesanan: ${e.message}');
    } catch (e) {
      debugPrint('Muat pesanan error: $e');
      throw PesananGagal('Gagal memuat pesanan, periksa koneksi internetmu');
    }

    // Ulasan diambil terpisah supaya kegagalannya tidak merusak daftar pesanan.
    final ulasan = <int, Map<String, dynamic>>{};

    try {
      final ids = [for (final m in data) m['id_pemesanan'] as int];

      if (ids.isNotEmpty) {
        final u = await _db
            .from('ulasan')
            .select('id_pemesanan, rating, komentar')
            .inFilter('id_pemesanan', ids);

        for (final r in u) {
          ulasan[r['id_pemesanan'] as int] = Map<String, dynamic>.from(r);
        }
      }
    } catch (e) {
      debugPrint('Muat ulasan dilewati: $e');
    }

    final sekarang = DateTime.now();
    final sekarangWib = _hariIniWib();
    final hasil = <Pesanan>[];

    for (final item in data) {
      final m = Map<String, dynamic>.from(item as Map);

      final statusDb = m['status_pesan'] as String;
      final dibuat = DateTime.parse(m['dibuat_pada'] as String).toLocal();
      final bayar = _daftar(m['pembayaran']);
      final sudahBayar = bayar.any(
        (x) => const ['berhasil', 'dibayar', 'lunas', 'paid']
            .contains('${x['status_bayar']}'.toLowerCase()),
      );

      if (statusDb == 'menunggu_pembayaran' &&
          sekarang.difference(dibuat).inMinutes >= 15) {
        continue;
      }
      // Status DB 'kadaluarsa' tetap diperlakukan sebagai pembayaran yang
      // kedaluwarsa; kedaluwarsa kunjungan dihitung dari pesanan aktif + tanggal.
      if (statusDb == 'kadaluarsa') continue;

      final kuota = _satu(m['kuota_harian']);
      final detailList = _daftar(m['detail_pemesanan']);
      final detailPertama = detailList.isEmpty ? null : detailList.first;
      final detailPaket = _satu(detailPertama?['detail_paket']);
      final paket = _satu(detailPaket?['paket_wisata']);
      final wisata = _satu(paket?['wisata']);

      final tglKunjungan = _tanggalWib(kuota?['tanggal']);
      final lewat =
          tglKunjungan != null && tglKunjungan.isBefore(sekarangWib);
      final selesai = statusDb == 'selesai';
      final kadaluarsa =
          statusDb == 'aktif' && sudahBayar && lewat;

      final StatusPesanan status;
      final String labelStatus;

      if (selesai) {
        status = StatusPesanan.selesai;
        labelStatus = 'Selesai';
      } else if (kadaluarsa) {
        status = StatusPesanan.kadaluarsa;
        labelStatus = 'Kadaluarsa';
      } else if (statusDb == 'menunggu_pembayaran') {
        status = StatusPesanan.terkonfirmasi;
        labelStatus = 'Menunggu Pembayaran';
      } else {
        status = StatusPesanan.siapDigunakan;
        labelStatus = 'Siap Digunakan';
      }

      final kategoriWisata = _satu(wisata?['kategori']);
      final namaKategori = '${kategoriWisata?['nama_kategori'] ?? ''}'.trim();
      final namaKategoriLower = namaKategori.toLowerCase();
      final tur =
          namaKategoriLower.contains('tur') ||
          namaKategoriLower.contains('open trip');

      // Peserta
      final jml = <String, int>{};

      for (final d in _daftar(m['detail_pemesanan'])) {
        final t = d['tipe_pengunjung'] as String;
        jml[t] = (jml[t] ?? 0) + (d['jumlah'] as int);
      }

      final peserta = [
        for (final e in _namaTipe.entries)
          if ((jml[e.key] ?? 0) > 0) '${jml[e.key]} ${e.value}',
      ].join(', ');

      // Pembayaran: pilih yang berhasil, kalau belum ada ambil yang pertama.
      final b = bayar.firstWhere(
        (x) => x['status_bayar'] == 'berhasil',
        orElse: () => bayar.isNotEmpty ? bayar.first : <String, dynamic>{},
      );
      final wisataId = (wisata?['id_wisata'] as num?)?.toInt() ?? 0;
      final fotoWisata = _daftar(wisata?['foto_wisata'])
        ..sort(
          (a, b) =>
              ((a['urutan'] ?? 0) as num).compareTo((b['urutan'] ?? 0) as num),
        );

      final buka = _jam(wisata?['jam_buka']);
      final tutup = _jam(wisata?['jam_tutup']);

      final idPemesanan = m['id_pemesanan'] as int;
      final u = ulasan[idPemesanan];

      hasil.add(
        Pesanan(
          id: m['kode_pesan'] as String,
          idPemesanan: idPemesanan,
          tglBeli: _tgl(DateTime.parse(m['tgl_pesan'] as String)),
          dibuat: dibuat,
          status: status,
          labelStatus: labelStatus,
          kategori: tur ? KategoriPesanan.tur : KategoriPesanan.tiketWisata,
          kategoriWisata: namaKategori.isEmpty ? 'Lainnya' : namaKategori,
          labelFoto: (wisata?['jenis'] as String?) ?? (tur ? 'Tur' : 'Tiket'),
          judul: (wisata?['nama_wisata'] as String?) ?? 'Wisata',
          fotoUrl: fotoWisata.isEmpty
              ? null
              : fotoWisata.first['url_foto'] as String?,
          lokasi:
              (wisata?['lokasi'] as String?) ??
              (wisata?['kota'] as String?) ??
              '-',
          chips: [
            (paket?['nama_paket'] as String?) ?? 'Paket',
            peserta.isEmpty ? '-' : peserta,
          ],
          labelJadwal: tur ? 'Jadwal Tur' : 'Jadwal Kunjungan',
          jadwal: tglKunjungan == null ? '-' : _tgl(tglKunjungan),
          tanggalKunjungan: tglKunjungan,
          jam: (buka != null && tutup != null) ? '$buka - $tutup' : null,
          labelTotal: statusDb == 'menunggu_pembayaran'
              ? 'Total Tagihan'
              : 'Total Bayar',
          total: formatRupiah(m['total_bayar'] as int),
          metode: _metode(b),
          rating: (u?['rating'] as num?)?.toDouble(),
          ulasan: u?['komentar'] as String?,
          bisaUlas:
              status == StatusPesanan.selesai &&
              u == null &&
              sudahBayar &&
              wisataId > 0,
          wisataId: wisataId,
          orderId: idPemesanan,
        ),
      );
    }

    return hasil;
  }

  Future<void> tandaiSelesai(int idPemesanan) async {
    try {
      await _db.rpc(
        'tandai_selesai',
        params: {'p_id_pemesanan': idPemesanan},
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'RPC tandai_selesai gagal: ${e.code} ${e.message} ${e.details}',
      );
      final pesan = e.message.toLowerCase();
      if (pesan.contains('hari kunjungan') ||
          pesan.contains('tanggal kunjungan')) {
        throw PesananGagal(
          'Pesanan hanya bisa ditandai selesai pada hari kunjungan.',
        );
      }
      if (pesan.contains('bukan milik') || pesan.contains('tidak terkait')) {
        throw PesananGagal('Pesanan ini bukan milik akun Anda.');
      }
      if (pesan.contains('sudah selesai') ||
          pesan.contains('hanya pesanan aktif')) {
        throw PesananGagal('Pesanan ini sudah tidak dapat ditandai selesai.');
      }
      if (pesan.contains('tidak ditemukan')) {
        throw PesananGagal('Pesanan tidak ditemukan.');
      }
      throw PesananGagal(
        'Gagal menandai pesanan selesai. Coba lagi nanti.',
      );
    } catch (e) {
      debugPrint('RPC tandai_selesai error: $e');
      throw PesananGagal('Gagal menandai pesanan selesai. Coba lagi.');
    }
  }

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
