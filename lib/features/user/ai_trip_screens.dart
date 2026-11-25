import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/app_color.dart';
import '../../models/ai_plan.dart';
import '../../models/wisata.dart';
import '../../services/ai_service.dart';
import '../../services/wisata_service.dart';
import '../../widgets/gambar_wisata.dart';
import 'detail_wisata_screens.dart';

class AiTripPromo extends StatelessWidget {
  final VoidCallback onTap;
  const AiTripPromo({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Card(color: const Color(0xFFF0F3FC), elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.route_rounded, color: AppColor.ungu, size: 30),
        title: const Text('Rencanakan trip dengan AI',
          style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Text('Ceritakan liburan yang kamu mau'),
        trailing: const Icon(Icons.arrow_forward_rounded, color: AppColor.ungu),
        onTap: onTap,
      )),
  );
}

class AiTripScreens extends StatefulWidget {
  const AiTripScreens({super.key});
  @override
  State<AiTripScreens> createState() => _AiTripScreensState();
}

class _AiTripScreensState extends State<AiTripScreens> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _riwayat = <Map<String, dynamic>>[];
  final _pesan = <_ChatEntry>[];
  bool _loading = false;

  @override
  void dispose() { _input.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _kirim([String? isi]) async {
    final teks = (isi ?? _input.text).trim();
    if (teks.isEmpty || _loading) return;
    _input.clear();
    setState(() { _pesan.add(_ChatEntry(user: true, teks: teks)); _loading = true; });
    _gulir();
    try {
      final plan = await AiService().tanya(teks, riwayat: _riwayat);
      final spots = await WisataService().getByIds(plan.semuaId.toSet().toList());
      if (!mounted) return;
      setState(() {
        _pesan.add(_ChatEntry(user: false, teks: plan.pesan, plan: plan,
          wisata: {for (final w in spots) w.id: w}));
        _riwayat
          ..add({'role': 'user', 'parts': [{'text': teks}]})
          ..add({'role': 'model', 'parts': [{'text': _jsonPlan(plan)}]});
        if (_riwayat.length > 12) _riwayat.removeRange(0, _riwayat.length - 12);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _pesan.add(_ChatEntry(user: false,
        teks: e is AiException ? e.pesan : 'Belum bisa membuat rencana. Coba lagi.')));
    } finally {
      if (mounted) { setState(() => _loading = false); _gulir(); }
    }
  }

  String _jsonPlan(AiPlan p) => jsonEncode({
    'pesan': p.pesan,
    'hari': p.hari.map((h) => {
      'hari_ke': h.hariKe, 'judul': h.judul,
      'stops': h.stops.map((s) => {
        'id_wisata': s.idWisata, 'waktu': s.waktu, 'alasan': s.alasan,
      }).toList(),
    }).toList(),
    'saran_lanjutan': p.saranLanjutan,
  });

  void _gulir() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FC),
    appBar: AppBar(
      title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Teman Trip', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        Text('Perencana wisata LokaTrip', style: TextStyle(fontSize: 11)),
      ]),
      elevation: 0, backgroundColor: AppColor.putih, foregroundColor: AppColor.hitam,
    ),
    body: Column(children: [
      Expanded(child: ListView(controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        children: [
          if (_pesan.isEmpty) _awal(),
          for (final item in _pesan) ...[
            _bubble(item),
            if (item.plan != null) _itinerary(item),
          ],
          if (_loading) const Align(alignment: Alignment.centerLeft,
            child: Padding(padding: EdgeInsets.all(12),
              child: SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)))),
        ],
      )),
      _composer(),
    ]),
  );

  Widget _awal() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColor.putih, borderRadius: BorderRadius.circular(18)),
      child: const Text('Hai! Mau liburan ke mana? Ceritakan sedikit saja, nanti kita susun bareng.',
        style: TextStyle(fontSize: 14, height: 1.5))),
    const SizedBox(height: 14),
    const Text('Mulai dari contoh ini', style: TextStyle(fontSize: 12,
      fontWeight: FontWeight.w700, color: Color(0xFF696E80))),
    const SizedBox(height: 8),
    for (final contoh in [
      'Buat itinerary 2 hari di Batu, aku suka alam',
      'Wisata santai di Malang untuk keluarga',
      'Aku punya satu hari di Batu, enaknya ke mana?',
    ])
      Padding(padding: const EdgeInsets.only(bottom: 8),
        child: ActionChip(label: Text(contoh, style: const TextStyle(fontSize: 12)),
          onPressed: _loading ? null : () => _kirim(contoh),
          backgroundColor: AppColor.putih,
          side: const BorderSide(color: Color(0xFFE3E6EF)))),
  ]);

  Widget _bubble(_ChatEntry item) => Align(
    alignment: item.user ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .82),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: item.user ? AppColor.ungu : AppColor.putih,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(17), topRight: const Radius.circular(17),
          bottomLeft: Radius.circular(item.user ? 17 : 5),
          bottomRight: Radius.circular(item.user ? 5 : 17))),
      child: Text(item.teks, style: TextStyle(
        color: item.user ? AppColor.putih : const Color(0xFF303448),
        fontSize: 13, height: 1.45)),
    ),
  );

  Widget _itinerary(_ChatEntry item) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final day in item.plan!.hari) ...[
        Padding(padding: const EdgeInsets.only(top: 5, bottom: 7),
          child: Text('Hari ${day.hariKe}  ${day.judul}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
        for (final stop in day.stops)
          if (item.wisata?[stop.idWisata] case final w?)
            Card(margin: const EdgeInsets.only(bottom: 8), color: AppColor.putih, elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                leading: ClipRRect(borderRadius: BorderRadius.circular(9),
                  child: SizedBox(width: 54, height: 54, child: GambarWisata(path: w.gambar))),
                title: Text(w.nama, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: Text('${stop.waktu}  ${stop.alasan}', maxLines: 2,
                  overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => DetailWisataScreens(wisata: w))))),
      ],
      if (item.plan!.hari.isEmpty && item.plan!.saranLanjutan.isNotEmpty)
        Wrap(spacing: 6, children: [
          for (final saran in item.plan!.saranLanjutan)
            ActionChip(label: Text(saran), onPressed: () => _kirim(saran)),
        ]),
    ]),
  );

  Widget _composer() => SafeArea(top: false,
    child: Container(padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
      decoration: const BoxDecoration(color: AppColor.putih,
        border: Border(top: BorderSide(color: Color(0xFFE8EAF0)))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: TextField(
          controller: _input, minLines: 1, maxLines: 4, maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: _loading ? null : (_) => _kirim(),
          decoration: InputDecoration(hintText: 'Tulis pesan...', counterText: '',
            filled: true, fillColor: const Color(0xFFF5F6FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide.none)))),
        const SizedBox(width: 8),
        IconButton.filled(onPressed: _loading ? null : () => _kirim(),
          style: IconButton.styleFrom(backgroundColor: AppColor.ungu,
            foregroundColor: AppColor.putih),
          icon: const Icon(Icons.arrow_upward_rounded), tooltip: 'Kirim pesan'),
      ])),
  );
}

class _ChatEntry {
  final bool user;
  final String teks;
  final AiPlan? plan;
  final Map<int, Wisata>? wisata;
  const _ChatEntry({required this.user, required this.teks, this.plan, this.wisata});
}
