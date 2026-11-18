// 799000 -> "Rp 799.000"
String formatRupiah(int angka) {
  final s = angka.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

// 31000 -> "31k", 2400 -> "2.4k", 850 -> "850"
String ringkasAngka(int n) {
  if (n < 1000) return '$n';
  final k = n / 1000;
  return k == k.roundToDouble() ? '${k.round()}k' : '${k.toStringAsFixed(1)}k';
}