// Isi banner promo di bagian atas halaman kategori.
class PromoKategori {
  final String label; // contoh: 'EKSKLUSIF LOKATRIP'
  final String judul;
  final String deskripsi;
  final String? periode; // contoh: 'Hingga 31 Mar'
  final String? kode; // ada = tampil kode + "Salin Kode"
  final String? tombol; // ada = tampil tombol di kanan, contoh: 'Klaim'

  const PromoKategori({
    required this.label,
    required this.judul,
    required this.deskripsi,
    this.periode,
    this.kode,
    this.tombol,
  });
}