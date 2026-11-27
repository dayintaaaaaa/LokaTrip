class AiStop {
  final int idWisata;
  final String waktu;
  final String alasan;

  const AiStop({
    required this.idWisata,
    required this.waktu,
    required this.alasan,
  });

  factory AiStop.fromJson(Map<String, dynamic> j) => AiStop(
        idWisata: (j['id_wisata'] as num).toInt(),
        waktu: j['waktu'] as String? ?? '',
        alasan: j['alasan'] as String? ?? '',
      );
}

class AiHari {
  final int hariKe;
  final String judul;
  final List<AiStop> stops;

  const AiHari({
    required this.hariKe,
    required this.judul,
    required this.stops,
  });

  factory AiHari.fromJson(Map<String, dynamic> j) => AiHari(
        hariKe: (j['hari_ke'] as num?)?.toInt() ?? 0,
        judul: j['judul'] as String? ?? '',
        stops: ((j['stops'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(AiStop.fromJson)
            .toList(),
      );
}

class AiPlan {
  final String pesan;
  final List<AiHari> hari;
  final List<String> saranLanjutan;

  const AiPlan({
    required this.pesan,
    required this.hari,
    required this.saranLanjutan,
  });

  factory AiPlan.fromJson(Map<String, dynamic> j) => AiPlan(
        pesan: j['pesan'] as String? ?? '',
        hari: ((j['hari'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(AiHari.fromJson)
            .where((h) => h.stops.isNotEmpty)
            .toList(),
        saranLanjutan: ((j['saran_lanjutan'] ?? []) as List)
            .whereType<String>()
            .toList(),
      );

  // semua id wisata yang disebut AI
  Iterable<int> get semuaId => hari.expand((h) => h.stops).map((s) => s.idWisata);
}