// Harga dan sisa kuota satu tanggal kunjungan.
class Ketersediaan {
  final int harga; // harga dewasa pada tanggal itu
  final int kuota; // sisa tiket
  const Ketersediaan({required this.harga, required this.kuota});

  bool get penuh => kuota <= 0;
}

// DUMMY: ganti dengan data kuota & harga dari backend.
class KetersediaanDummy {
  static const int maksTiketPerTransaksi = 10;

  static Ketersediaan untuk(DateTime tgl, int hargaDasar) {
    // akhir pekan +10%, dibulatkan supaya harganya tetap "bulat"
    final akhirPekan =
        tgl.weekday == DateTime.saturday || tgl.weekday == DateTime.sunday;
    final langkah = hargaDasar >= 200000
        ? 10000
        : hargaDasar >= 50000
            ? 5000
            : 1000;
    final harga =
        akhirPekan ? (hargaDasar * 1.1 / langkah).round() * langkah : hargaDasar;

    // pola tetap dari tanggal (bukan acak) supaya tidak berubah saat rebuild
    final pola = (tgl.day * 7 + tgl.month * 3) % 11;
    final kuota = pola == 0 ? 0 : 4 + (pola * 3) % 22;

    return Ketersediaan(harga: harga, kuota: kuota);
  }

  // harga anak = 2/3 harga dewasa, dibulatkan ke 1.000
  static int hargaAnak(int hargaDewasa) =>
      (hargaDewasa * 2 / 3 / 1000).round() * 1000;
}