import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api_client.dart';
import '../../core/app_color.dart';
import '../../core/pesanan_model.dart';
import '../../core/session_manager.dart';
import '../../services/pesanan_service.dart';
import '../../widgets/sub_app_bar.dart';

class UlasanWisataScreens extends StatefulWidget {
  final String? orderId;
  const UlasanWisataScreens({super.key, this.orderId});
  @override
  State<UlasanWisataScreens> createState() => _UlasanWisataScreensState();
}

class _UlasanWisataScreensState extends State<UlasanWisataScreens> {
  late Future<_DataUlasan> _data;
  bool _sudahDiulas = true;
  bool _autoBuka = false;

  @override
  void initState() {
    super.initState();
    _data = _muat();
  }

  Future<_DataUlasan> _muat() async {
    final token = await SessionManager.currentUserToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Silakan masuk untuk melihat ulasan.');
    }
    final ulasan = await UserApi.reviews(token);
    final pesanan = await PesananService().ambilSemua();
    final sudah = ulasan.map((u) => (u['id_pemesanan'] as num?)?.toInt())
        .whereType<int>().toSet();
    final belum = pesanan.where((p) => p.bisaUlas && !sudah.contains(p.orderId)).toList();
    return _DataUlasan(ulasan: ulasan, pesanan: belum);
  }

  Future<void> _bukaForm(Pesanan pesanan) async {
    final berhasil = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => _FormUlasan(pesanan: pesanan)));
    if (berhasil != true || !mounted) return;
    setState(() {
      _sudahDiulas = true;
      _data = _muat();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Ulasan berhasil disimpan ke akunmu.'),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColor.latar,
    body: Column(children: [
      const SubAppBar(title: 'Ulasan Wisata'),
      Expanded(child: FutureBuilder<_DataUlasan>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
            ));
          }
          final data = snapshot.data!;
          if (widget.orderId != null && !_autoBuka) {
            _autoBuka = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final id = int.tryParse(widget.orderId!);
              final p = data.pesanan.where((o) => o.orderId == id).firstOrNull;
              if (p != null && mounted) _bukaForm(p);
            });
          }
          final rating = data.ulasan.isEmpty ? 0.0 : data.ulasan
              .map((u) => (u['rating'] as num?)?.toDouble() ?? 0)
              .reduce((a, b) => a + b) / data.ulasan.length;
          return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColor.putih,
                  borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  const Icon(Icons.star_rounded, color: AppColor.kuning, size: 25),
                  const SizedBox(width: 8),
                  Text(data.ulasan.isEmpty ? '' : rating.toStringAsFixed(1),
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 12),
                  Text(data.ulasan.length.toString() + ' ulasan tersimpan',
                    style: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu)),
                ]),
              ),
              const SizedBox(height: 14),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true,
                    label: Text('Sudah diulas (' + data.ulasan.length.toString() + ')')),
                  ButtonSegment(value: false,
                    label: Text('Belum diulas (' + data.pesanan.length.toString() + ')')),
                ],
                selected: {_sudahDiulas},
                onSelectionChanged: (v) => setState(() => _sudahDiulas = v.first),
              ),
              const SizedBox(height: 12),
              if (_sudahDiulas)
                if (data.ulasan.isEmpty)
                  _kosong('Belum ada ulasan', 'Ulasan yang kamu kirim akan tersimpan di sini.')
                else
                  for (final row in data.ulasan) _kartuUlasan(row)
              else
                if (data.pesanan.isEmpty)
                  _kosong('Belum ada pesanan yang bisa diulas',
                    'Ulasan tersedia setelah kunjungan selesai dan pembayaran berhasil.')
                else
                  for (final p in data.pesanan) _kartuPesanan(p, () => _bukaForm(p)),
            ],
          );
        },
      )),
    ]),
  );

  Widget _kosong(String judul, String isi) => Padding(
    padding: const EdgeInsets.only(top: 54),
    child: Column(children: [
      const Icon(Icons.rate_review_outlined, size: 42, color: AppColor.abu),
      const SizedBox(height: 12),
      Text(judul, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      Text(isi, textAlign: TextAlign.center,
        style: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu)),
    ]),
  );

  Widget _kartuPesanan(Pesanan p, VoidCallback tap) => Card(
    color: AppColor.putih, elevation: 0, margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: const CircleAvatar(backgroundColor: Color(0xFFEAF1FB),
        child: Icon(Icons.place_outlined, color: AppColor.ungu)),
      title: Text(p.judul, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(p.lokasi + '  ' + p.jadwal + '\nPesanan ' + p.id,
        style: GoogleFonts.manrope(fontSize: 11, height: 1.5)),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right, color: AppColor.ungu),
      onTap: tap,
    ),
  );

  Widget _kartuUlasan(Map<String, dynamic> row) {
    final raw = row['wisata'];
    final wisata = raw is Map<String, dynamic> ? raw
        : raw is List && raw.isNotEmpty ? Map<String, dynamic>.from(raw.first as Map)
        : <String, dynamic>{};
    final rating = (row['rating'] as num?)?.toInt() ?? 0;
    final tanggal = row['tanggal_ulasan']?.toString() ?? '';
    return Card(
      color: AppColor.putih, elevation: 0, margin: const EdgeInsets.only(bottom: 10),
      child: Padding(padding: const EdgeInsets.all(14), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(wisata['nama_wisata']?.toString() ?? 'Wisata',
            style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Row(children: [
            for (var i = 1; i <= 5; i++)
              Icon(Icons.star_rounded, size: 17,
                color: i <= rating ? AppColor.kuning : const Color(0xFFD9DDE5)),
            const SizedBox(width: 8),
            if (tanggal.length >= 10)
              Text(tanggal.substring(0, 10), style: GoogleFonts.manrope(
                fontSize: 10, color: AppColor.abu)),
          ]),
          if ((row['komentar'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(row['komentar'] as String,
              style: GoogleFonts.manrope(fontSize: 12, height: 1.45)),
          ],
        ],
      )),
    );
  }
}

class _DataUlasan {
  final List<Map<String, dynamic>> ulasan;
  final List<Pesanan> pesanan;
  const _DataUlasan({required this.ulasan, required this.pesanan});
}

class _FormUlasan extends StatefulWidget {
  final Pesanan pesanan;
  const _FormUlasan({required this.pesanan});
  @override
  State<_FormUlasan> createState() => _FormUlasanState();
}

class _FormUlasanState extends State<_FormUlasan> {
  final _komentar = TextEditingController();
  int _rating = 0;
  bool _loading = false;

  @override
  void dispose() { _komentar.dispose(); super.dispose(); }

  Future<void> _kirim() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rating bintang terlebih dahulu.')));
      return;
    }
    setState(() => _loading = true);
    try {
      final token = await SessionManager.currentUserToken();
      if (token == null || token.isEmpty) {
        throw const ApiException('Sesi login tidak ditemukan.');
      }
      await UserApi.createReview(
        token: token,
        orderId: widget.pesanan.orderId,
        wisataId: widget.pesanan.wisataId,
        rating: _rating,
        comment: _komentar.text.trim().isEmpty ? null : _komentar.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColor.latar,
    appBar: AppBar(title: const Text('Tulis Ulasan'),
      backgroundColor: AppColor.putih, foregroundColor: AppColor.hitam),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(widget.pesanan.judul, style: GoogleFonts.outfit(
        fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(widget.pesanan.lokasi + '  ' + widget.pesanan.jadwal,
        style: GoogleFonts.manrope(fontSize: 12, color: AppColor.abu)),
      const SizedBox(height: 26),
      Text('Bagaimana pengalamanmu?', textAlign: TextAlign.center,
        style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            onPressed: _loading ? null : () => setState(() => _rating = i),
            icon: Icon(Icons.star_rounded, size: 38,
              color: i <= _rating ? AppColor.kuning : const Color(0xFFD9DDE5)),
          ),
      ]),
      TextField(controller: _komentar, minLines: 4, maxLines: 7,
        maxLength: 1000, textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Ceritakan pengalamanmu (opsional)',
          filled: true, fillColor: AppColor.putih,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        )),
      const SizedBox(height: 12),
      SizedBox(height: 50, child: FilledButton(
        onPressed: _loading ? null : _kirim,
        style: FilledButton.styleFrom(backgroundColor: AppColor.ungu),
        child: _loading ? const SizedBox(width: 20, height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Kirim Ulasan'),
      )),
    ]),
  );
}
