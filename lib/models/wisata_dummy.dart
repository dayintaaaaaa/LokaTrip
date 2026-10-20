import '../models/wisata.dart';

class WisataDummy {
  // waktu berakhir dihitung sekali (static), jadi timer tidak
  // mulai ulang setiap Home dibangun ulang
  static final DateTime flashSaleBerakhir = DateTime.now().add(
    const Duration(hours: 4, minutes: 28, seconds: 10),
  );

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
}