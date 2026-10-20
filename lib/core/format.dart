// format angka ribuan: 24500 -> 24.500
String formatAngka(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}