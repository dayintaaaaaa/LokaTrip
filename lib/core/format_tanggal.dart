const _bulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const _bulanSingkat = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

// 3 -> "Maret"
String namaBulan(int bulan) => _bulan[bulan - 1];

// 10 -> "Okt"
String namaBulanSingkat(int bulan) => _bulanSingkat[bulan - 1];

// DateTime(2026, 11, 28) -> "28 November 2026"
String formatTanggal(DateTime d) => '${d.day} ${namaBulan(d.month)} ${d.year}';