import 'format_rupiah.dart';

enum KategoriPesanan { tiketWisata, tur }

enum StatusPesanan { siapDigunakan, terkonfirmasi, selesai }

class Pesanan {
  final String id; // kode_pesan
  final int idPemesanan;
  final String tglBeli;
  final DateTime? dibuat;
  final StatusPesanan status;
  final String labelStatus;
  final KategoriPesanan kategori;
  final String labelFoto;
  final String judul;
  final String lokasi;
  final List<String> chips; // [nama paket, peserta]
  final String labelJadwal;
  final String jadwal;
  final String? jam;
  final String labelTotal;
  final String total;
  final String? catatanTotal;
  final String metode;
  final bool bisaUlas;
  double? rating;
  String? ulasan;
  final int wisataId;
  final int orderId;

  Pesanan({
    required this.id,
    this.idPemesanan = 0,
    required this.tglBeli,
    this.dibuat,
    required this.status,
    required this.labelStatus,
    required this.kategori,
    required this.labelFoto,
    required this.judul,
    required this.lokasi,
    required this.chips,
    required this.labelJadwal,
    required this.jadwal,
    this.jam,
    required this.labelTotal,
    required this.total,
    this.catatanTotal,
    required this.metode,
    this.bisaUlas = true,
    this.rating,
    this.ulasan,
    this.wisataId = 0,
    this.orderId = 0,
  });

  bool get aktif => status != StatusPesanan.selesai;

  factory Pesanan.fromApiJson(Map<String, dynamic> json) {
    Map<String, dynamic>? firstMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
        return value.first as Map<String, dynamic>;
      }
      return null;
    }

    final payment = firstMap(json['pembayaran']);
    final details = json['detail_pemesanan'];
    final firstDetail = details is List && details.isNotEmpty
        ? firstMap(details.first)
        : null;
    final package = firstMap(firstDetail?['detail_paket'] == null
        ? null
        : firstMap(firstDetail?['detail_paket'])?['paket_wisata']);
    final attraction = firstMap(package?['wisata']);
    final paymentStatus = (payment?['status_bayar'] as String? ?? '').toLowerCase();
    final orderStatus = (json['status_pesan'] as String? ?? '').toLowerCase();
    final selesai = orderStatus == 'kadaluarsa';
    final paid = const {'berhasil', 'dibayar', 'lunas', 'paid'}.contains(paymentStatus);
    final dateText = json['tgl_pesan'] as String? ?? '';
    final orderDate = DateTime.tryParse(dateText);
    final visitDate = firstMap(json['kuota_harian'])?['tanggal'] as String? ?? '';
    final guests = details is List
        ? details.fold<int>(0, (sum, row) => sum + ((firstMap(row)?['jumlah'] as num?)?.toInt() ?? 0))
        : 0;
    final rawId = (json['id_pemesanan'] as num?)?.toInt() ?? 0;
    final wisataId = (attraction?['id_wisata'] as num?)?.toInt() ?? 0;
    final title = attraction?['nama_wisata'] as String? ?? package?['nama_paket'] as String? ?? 'Pesanan LokaTrip';
    final location = attraction?['lokasi'] as String? ?? '';
    final total = (json['total_bayar'] as num?)?.toInt() ?? 0;
    final packageName = package?['nama_paket'] as String? ?? 'Tiket wisata';

    return Pesanan(
      id: json['kode_pesan'] as String? ?? '$rawId',
      idPemesanan: rawId,
      wisataId: wisataId,
      orderId: rawId,
      tglBeli: orderDate == null
          ? dateText
          : '${orderDate.day} ${_bulanSingkat[orderDate.month - 1]} ${orderDate.year}',
      status: selesai ? StatusPesanan.selesai : paid ? StatusPesanan.siapDigunakan : StatusPesanan.terkonfirmasi,
      labelStatus: selesai ? 'Kedaluwarsa' : paid ? 'Siap Digunakan' : 'Menunggu Pembayaran',
      kategori: KategoriPesanan.tiketWisata,
      labelFoto: 'Tiket Wisata',
      judul: title,
      lokasi: location,
      chips: [packageName, '$guests Pengunjung'],
      labelJadwal: 'Jadwal Kunjungan',
      jadwal: visitDate.isEmpty ? 'Belum ditentukan' : visitDate,
      labelTotal: 'Total Pesanan',
      total: formatRupiah(total),
      metode: payment?['metode_bayar'] as String? ?? 'Belum dipilih',
      bisaUlas: paid && !selesai,
    );
  }
}

const _bulanSingkat = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

class DataPesanan {
  static final List<Pesanan> semua = [
    // ---------- aktif ----------
    Pesanan(
      id: 'LKT-89210492',
      tglBeli: 'Hari ini, 24 Okt',
      status: StatusPesanan.siapDigunakan,
      labelStatus: 'Siap Digunakan',
      kategori: KategoriPesanan.tiketWisata,
      labelFoto: 'Tiket',
      judul: 'Waterbom Bali - All Day Access Pass',
      lokasi: 'Kuta, Bali',
      chips: ['Instant Pass', '1 Dewasa'],
      labelJadwal: 'Jadwal Kunjungan',
      jadwal: 'Besok, 25 Okt 2024',
      jam: '09:00 - 18:00 WITA',
      labelTotal: 'Total Bayar',
      total: 'Rp 137.500',
            metode: 'QRIS',
    ),
    Pesanan(
      id: 'LKT-78391024',
      tglBeli: '22 Okt 2024',
      status: StatusPesanan.terkonfirmasi,
      labelStatus: 'Terkonfirmasi',
      kategori: KategoriPesanan.tur,
      labelFoto: 'Tur',
      judul: 'Borobudur Sunrise VIP Pass & Walking Tour',
      lokasi: 'Magelang, Jawa Tengah',
      chips: ['Guide Termasuk', '2 Pengunjung'],
      labelJadwal: 'Jadwal Tur',
      jadwal: 'Minggu, 27 Okt 2024',
      jam: '04:30 WIB (Pintu Kenari)',
      labelTotal: 'Total Tagihan',
      total: 'Rp 220.000',
      catatanTotal: 'BCA Virtual Account',
      metode: 'BCA Virtual Account',
    ),

    // ---------- selesai ----------
    Pesanan(
      id: 'LKT-67210981',
      tglBeli: '12 Okt 2024',
      status: StatusPesanan.selesai,
      labelStatus: 'Telah Dikunjungi',
      kategori: KategoriPesanan.tiketWisata,
      labelFoto: 'Atraksi',
      judul: 'Taman Safari Indonesia Cisarua',
      lokasi: 'Puncak, Bogor',
      chips: ['Safari Journey + 9 Shows', '2 Dewasa'],
      labelJadwal: 'Jadwal Kunjungan',
      jadwal: '15 Okt 2024',
      labelTotal: 'Total Bayar (BCA VA)',
      total: 'Rp 360.000',
      metode: 'BCA Virtual Account',
    ),
    Pesanan(
      id: 'LKT-55198203',
      tglBeli: '28 Sep 2024',
      status: StatusPesanan.selesai,
      labelStatus: 'Selesai',
      kategori: KategoriPesanan.tiketWisata,
      labelFoto: 'Budaya',
      judul: 'Garuda Wisnu Kencana (GWK) Cultural',
      lokasi: 'Jimbaran, Bali',
      chips: ['Tiket Reguler + Drink', '1 Pengunjung'],
      labelJadwal: 'Jadwal Kunjungan',
      jadwal: '1 Okt 2024',
      labelTotal: 'Total Bayar (QRIS)',
      total: 'Rp 80.000',
      metode: 'QRIS',
      rating: 5,
      ulasan:
          'Pemandangannya bagus banget dan patungnya megah, cocok untuk foto keluarga!',
    ),
    Pesanan(
      id: 'LKT-44120911',
      tglBeli: '14 Agu 2024',
      status: StatusPesanan.selesai,
      labelStatus: 'Selesai',
      kategori: KategoriPesanan.tur,
      labelFoto: 'Tur Alam',
      judul: 'Open Trip Bromo Midnight Sunrise VIP',
      lokasi: 'Bromo, Jawa Timur',
      chips: ['Paket Jeep 4x4', '2 Peserta'],
      labelJadwal: 'Jadwal Tur',
      jadwal: '18 Agu 2024',
      labelTotal: 'Total Bayar',
      total: 'Rp 600.000',
      metode: 'QRIS',
      bisaUlas: false, // masa pemberian ulasan sudah lewat
    ),
    Pesanan(
      id: 'LKT-33009871',
      tglBeli: '20 Jul 2024',
      status: StatusPesanan.selesai,
      labelStatus: 'Selesai',
      kategori: KategoriPesanan.tiketWisata,
      labelFoto: 'Theme Park',
      judul: 'Jatim Park 3 & Dino Park Terusan',
      lokasi: 'Batu, Malang',
      chips: ['Tiket Terusan', '2 Dewasa'],
      labelJadwal: 'Jadwal Kunjungan',
      jadwal: '23 Jul 2024',
      labelTotal: 'Total Bayar (QRIS)',
      total: 'Rp 196.000',
      metode: 'QRIS',
      rating: 4,
      ulasan: 'Wahananya seru, cuma antrean di akhir pekan lumayan panjang.',
    ),
    Pesanan(
      id: 'LKT-22118740',
      tglBeli: '2 Jul 2024',
      status: StatusPesanan.selesai,
      labelStatus: 'Selesai',
      kategori: KategoriPesanan.tur,
      labelFoto: 'Tur Jeep',
      judul: 'Jeep Lava Tour Merapi Adventure',
      lokasi: 'Sleman, Yogyakarta',
      chips: ['Jeep Offroad', '4 Peserta'],
      labelJadwal: 'Jadwal Tur',
      jadwal: '5 Jul 2024',
      labelTotal: 'Total Bayar',
      total: 'Rp 350.000',
      metode: 'BCA Virtual Account',
      bisaUlas: false,
    ),
  ];
}
