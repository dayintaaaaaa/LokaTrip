enum KategoriPesanan { tiketWisata, tur }

enum StatusPesanan { siapDigunakan, terkonfirmasi, selesai }

// ganti model dan data ini dengan yang dari backend
class Pesanan {
  final String id;
  final String tglBeli;
  final StatusPesanan status;
  final String labelStatus;
  final KategoriPesanan kategori;
  final String labelFoto;
  final String judul;
  final String lokasi;
  final List<String> chips;
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

  Pesanan({
    required this.id,
    required this.tglBeli,
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
  });

  bool get aktif => status != StatusPesanan.selesai;
}

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
      labelTotal: 'Total Bayar (Flash Sale)',
      total: 'Rp 137.500',
      catatanTotal: 'Hemat 45%',
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