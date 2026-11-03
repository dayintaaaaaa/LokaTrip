import '../models/wisata.dart';

class WisataDummy {
  // waktu berakhir dihitung sekali (static), jadi timer tidak
  // mulai ulang setiap Home dibangun ulang
  static final DateTime flashSaleBerakhir = DateTime.now().add(
    const Duration(hours: 4, minutes: 28, seconds: 10),
  );

  // gabungan semua wisata, dipakai Wishlist untuk mencari id yang difavoritkan.
  // id harus unik antar daftar.
  static List<Wisata> get semuaWisata => [
    ...flashSale,
    ...populer,
    ...tripAkhirPekan,
    ...flashKilat,
    ...terpopuler,
    ...katalog,
    ...destinasiPopuler,
  ];

  static const List<Wisata> flashSale = [
    Wisata(
      id: 1,
      nama: '1-Day Speedboat Tour Komodo & Pulau Padar',
      lokasi: 'Labuan Bajo, NTT',
      harga: 799000,
      hargaAsli: 1450000,
      sisaTiket: 4,
    ),
    Wisata(
      id: 2,
      nama: 'Borobudur Sunrise & Stupa Tour',
      lokasi: 'Magelang, Jawa Tengah',
      harga: 275000,
      hargaAsli: 500000,
      sisaTiket: 12,
    ),
    Wisata(
      id: 3,
      nama: 'Nusa Penida Day Trip Instagramable',
      lokasi: 'Klungkung, Bali',
      harga: 390000,
      hargaAsli: 650000,
      sisaTiket: 7,
    ),
  ];

  static const List<Wisata> populer = [
    Wisata(
      id: 11,
      nama: 'Dunia Fantasi (Dufan) Ancol',
      lokasi: 'Jakarta Utara',
      harga: 225000,
      rating: 4.8,
      jumlahUlasan: 31000,
      tipe: 'Instant Pass',
      kategori: 'Taman Rekreasi',
      bisaRefund: true,
    ),
    Wisata(
      id: 12,
      nama: 'Midnight Bromo Sunrise Tour',
      lokasi: 'Malang / Probolinggo',
      harga: 350000,
      rating: 4.7,
      jumlahUlasan: 2400,
      tipe: 'Open Trip',
      kategori: 'Wisata Alam',
      bisaRefund: true,
    ),
    Wisata(
      id: 13,
      nama: 'Kawah Ijen Blue Fire Trekking',
      lokasi: 'Banyuwangi, Jawa Timur',
      harga: 300000,
      rating: 4.9,
      jumlahUlasan: 1800,
      tipe: 'Open Trip',
      kategori: 'Wisata Alam',
    ),
  ];

  static const List<Wisata> tripAkhirPekan = [
    Wisata(
      id: 21,
      nama: 'Island Hopping & Snorkeling Pulau Pari',
      lokasi: 'Meeting Point Muara Angke',
      harga: 185000,
      rating: 4.9,
      tipe: 'Open Trip',
      ulasan: 'Guide ramah, spot fotonya keren!',
      labelGambar: 'Day Trip',
      termasuk: 'Termasuk Alat Snorkel & Makan Siang',
      satuanHarga: '/orang',
    ),
    Wisata(
      id: 22,
      nama: 'Kintamani Sunrise Glamping & Onsen View',
      lokasi: 'Kintamani, Bangli',
      harga: 450000,
      rating: 4.95,
      tipe: 'Wellness & Relax',
      ulasan: 'Pemandangan Gunung Batur luar biasa',
      labelGambar: 'Staycation',
      termasuk: 'Termasuk Tiket Masuk & Sarapan',
      satuanHarga: '/malam',
    ),
    Wisata(
      id: 23,
      nama: 'Pemandian Air Panas Alami Cangar & Hutan Pinus',
      lokasi: 'Batu, Malang',
      harga: 25000,
      rating: 4.7,
      tipe: 'Relaksasi Alam',
      ulasan: 'Air hangatnya nyaman banget',
      labelGambar: 'Tiket Masuk',
      termasuk: 'Bebas Antre Tiket Fisik',
      satuanHarga: '/tiket',
    ),
  ];

  // waktu berakhir dihitung sekali (static final, bukan const)
  static final DateTime kilatBerakhir = DateTime.now().add(
    const Duration(hours: 4, minutes: 12, seconds: 35),
  );

  static final DateTime bannerBerakhir = DateTime.now().add(
    const Duration(hours: 8, minutes: 24, seconds: 12),
  );

  static const List<Wisata> flashKilat = [
    Wisata(
      id: 201,
      nama: 'Jatim Park 3 Dino Park',
      lokasi: 'Batu, Malang',
      kota: 'Malang',
      harga: 95000,
      hargaAsli: 135000,
      terjualPersen: 78,
    ),
    Wisata(
      id: 202,
      nama: 'GWK Cultural Park',
      lokasi: 'Ungasan, Badung',
      kota: 'Bali',
      harga: 85000,
      hargaAsli: 115000,
      terjualPersen: 85,
      sisaTiket: 8,
    ),
    Wisata(
      id: 203,
      nama: 'Saloka Theme Park',
      lokasi: 'Ambarawa, Semarang',
      kota: 'Semarang',
      harga: 110000,
      hargaAsli: 138000,
      terjualPersen: 55,
    ),
  ];

  static const List<Wisata> terpopuler = [
    Wisata(
      id: 301,
      nama: 'Candi Borobudur Heritage & Sunrise Pass',
      lokasi: 'Magelang, Jawa Tengah',
      kota: 'Magelang',
      harga: 50000,
      hargaAsli: 75000,
      rating: 4.9,
      jumlahUlasan: 12800,
      tipe: 'Konfirmasi Instan',
    ),
    Wisata(
      id: 302,
      nama: 'Candi Prambanan & Ramayana Ballet',
      lokasi: 'Sleman, Yogyakarta',
      kota: 'Yogyakarta',
      harga: 65000,
      hargaAsli: 85000,
      rating: 4.8,
      jumlahUlasan: 8400,
      poin: 450,
    ),
    Wisata(
      id: 303,
      nama: 'Taman Safari Prigen Tiket Reguler',
      lokasi: 'Prigen, Pasuruan',
      kota: 'Pasuruan',
      harga: 120000,
      hargaAsli: 150000,
      rating: 4.7,
      jumlahUlasan: 6100,
      tipe: 'Konfirmasi Instan',
      poin: 300,
    ),
  ];

  static const List<Wisata> katalog = [
    Wisata(
      id: 401,
      nama: 'Pantai Parangtritis Jeep Adventure & Gumuk Pasir Sunset',
      lokasi: 'Bantul, Yogyakarta',
      kota: 'Yogyakarta',
      subkategori: 'Petualangan Offroad & Pantai',
      harga: 320000,
      hargaAsli: 375000,
      rating: 4.8,
      jumlahUlasan: 850,
      satuanHarga: '/jeep',
    ),
    Wisata(
      id: 402,
      nama: 'Goa Pindul & Sungai Oya Cave Tubing + Pemandu Berpengalaman',
      lokasi: 'Gunungkidul, Yogyakarta',
      kota: 'Yogyakarta',
      subkategori: 'Cave Tubing & Susur Sungai',
      harga: 45000,
      hargaAsli: 60000,
      rating: 4.7,
      jumlahUlasan: 1200,
      satuanHarga: '/orang',
    ),
    Wisata(
      id: 403,
      nama: 'HeHa Sky View Tiket Masuk Reguler & All Spot Foto Selfie',
      lokasi: 'Patuk, Gunungkidul',
      kota: 'Yogyakarta',
      subkategori: 'Sunset View & Spot Foto',
      harga: 25000,
      hargaAsli: 30000,
      rating: 4.7,
      jumlahUlasan: 2100,
      satuanHarga: '/orang',
    ),
  ];

  static const List<Wisata> destinasiPopuler = [
    Wisata(
      id: 501,
      nama: 'Candi Borobudur Heritage & Sunrise Access',
      lokasi: 'Magelang, Jawa Tengah',
      kota: 'Jawa Tengah',
      subkategori: 'Cagar Budaya UNESCO',
      labelGambar: '#1 TERLARIS MINGGU INI',
      harga: 65000,
      hargaAsli: 75000,
      rating: 4.9,
      jumlahUlasan: 14200,
      satuanHarga: '/orang',
      fitur: ['Konfirmasi Instan', 'Bisa Reschedule'],
      bonus: 'Bonus Cashback 10% Poin Loka',
    ),
    Wisata(
      id: 502,
      nama: 'Garuda Wisnu Kencana (GWK) Cultural Park',
      lokasi: 'Badung, Bali',
      kota: 'Bali',
      subkategori: 'Taman Budaya & Teater',
      labelGambar: '#2 Terpopuler Bali',
      harga: 90000,
      hargaAsli: 125000,
      rating: 4.8,
      jumlahUlasan: 3800,
      satuanHarga: '/orang',
      fitur: ['Tiket Masuk Langsung Scan', 'Gratis Masuk Area Artisan'],
    ),
    Wisata(
      id: 503,
      nama: 'Candi Prambanan & Pertunjukan Ramayana',
      lokasi: 'Sleman, D.I. Yogyakarta',
      kota: 'Yogyakarta',
      subkategori: 'Wisata Sejarah',
      labelGambar: '#3 Wisata Budaya',
      harga: 65000,
      hargaAsli: 85000,
      rating: 4.8,
      jumlahUlasan: 2400,
      satuanHarga: '/orang',
      fitur: ['E-Voucher Langsung Terbit', 'Termasuk Tiket Masuk'],
    ),
    Wisata(
      id: 504,
      nama: 'Jatim Park 3 & Dino Park Terusan',
      lokasi: 'Batu, Jawa Timur',
      kota: 'Jawa Timur',
      subkategori: 'Theme Park & Edukasi',
      labelGambar: 'Pilihan Keluarga',
      harga: 98000,
      hargaAsli: 140000,
      rating: 4.8,
      jumlahUlasan: 1900,
      satuanHarga: '/orang',
      fitur: ['Akses Terusan', 'Kids Friendly'],
    ),
    Wisata(
      id: 505,
      nama: 'Pantai Parangtritis Sunset Jeep Adventure',
      lokasi: 'Bantul, Yogyakarta',
      kota: 'Yogyakarta',
      subkategori: 'Outdoor Adventure',
      labelGambar: '#5 Wisata Adrenalin',
      harga: 320000,
      rating: 4.8,
      jumlahUlasan: 850,
      satuanHarga: '/jeep',
      fitur: ['Gratis Driver & BBM', 'Termasuk Asuransi'],
    ),
  ];
}
