// Satu kupon: potongan tetap (Rp) ATAU persen dengan batas maksimal.
class Kupon {
  final String kode;
  final int? potongan; // contoh: 50000
  final int? persen; // contoh: 25
  final int? maksPotongan; // batas atas untuk kupon persen

  const Kupon({
    required this.kode,
    this.potongan,
    this.persen,
    this.maksPotongan,
  });

  // besar diskon untuk subtotal tiket tertentu
  int hitung(int subtotal) {
    var diskon = potongan ?? (persen == null ? 0 : subtotal * persen! ~/ 100);
    if (maksPotongan != null && diskon > maksPotongan!) diskon = maksPotongan!;
    return diskon > subtotal ? subtotal : diskon;
  }
}

// DUMMY: ganti dengan validasi kupon dari backend.
class KuponDummy {
  // kupon yang langsung terpasang saat halaman checkout dibuka (sesuai desain)
  static const bawaan = Kupon(kode: 'LOKATRIPHEMAT', potongan: 50000);

  static const _daftar = [
    bawaan,
    Kupon(kode: 'KELANABUDAYA', persen: 25, maksPotongan: 75000),
  ];

  // null = kode tidak ditemukan
  static Kupon? cari(String kode) {
    final k = kode.trim().toUpperCase();
    for (final kupon in _daftar) {
      if (kupon.kode == k) return kupon;
    }
    return null;
  }
}