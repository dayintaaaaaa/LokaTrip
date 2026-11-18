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

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

// DateTime.saturday (6) -> "Sabtu"
String namaHari(int weekday) => _hari[weekday - 1];

// DateTime(2026, 10, 28) -> "Rabu, 28 Okt 2026"
String formatTanggalPendek(DateTime d) =>
    '${namaHari(d.weekday)}, ${d.day} ${namaBulanSingkat(d.month)} ${d.year}';