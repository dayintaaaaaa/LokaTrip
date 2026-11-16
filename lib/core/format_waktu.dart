import '../models/data_pemesanan.dart';

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String tglPendek(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';
String tglPanjang(DateTime d) => '${_hari[d.weekday - 1]}, ${tglPendek(d)}';

String formatWaktu(Duration d) {
  String dua(int n) => n.toString().padLeft(2, '0');
  return '${dua(d.inMinutes)}:${dua(d.inSeconds % 60)}';
}

extension TeksPesanan on DataPemesanan {
  // "2 Dewasa, 1 Anak, 1 Bayi"
  String get teksTamu {
    final p = <String>[
      if (dewasa > 0) '$dewasa Dewasa',
      if (anak > 0) '$anak Anak',
      if (bayi > 0) '$bayi Bayi',
    ];
    return p.join(', ');
  }
}