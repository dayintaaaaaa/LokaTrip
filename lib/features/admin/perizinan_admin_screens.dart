import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/admin_bottom_navigator.dart';
import '../../widgets/admin_notification_button.dart';
import 'dashboard_admin_screens.dart';
import 'laporan_admin_screens.dart';
import 'mitra_admin_screens.dart';
import 'notifikasi_admin_screens.dart';
import 'profil_screens.dart';

const _blue = Color(0xFF1D4ED8);
const _ink = Color(0xFF10243A);
const _muted = Color(0xFF667085);
const _page = Color(0xFFF5F7FB);
const _border = Color(0xFFE7EBF2);
const _green = Color(0xFF087457);
const _red = Color(0xFFCB3038);

enum _Status { active, pending, expiring, expired }

class _Permit {
  final String id, category, destination, partner, dates, note, auditor;
  final IconData icon;
  final Color iconBackground;
  _Status status;

  _Permit(
    this.id,
    this.category,
    this.destination,
    this.partner,
    this.dates,
    this.note,
    this.auditor,
    this.icon,
    this.iconBackground,
    this.status,
  );
}

class PerizinanAdminScreens extends StatefulWidget {
  const PerizinanAdminScreens({super.key});

  @override
  State<PerizinanAdminScreens> createState() => _PerizinanAdminScreensState();
}

class _PerizinanAdminScreensState extends State<PerizinanAdminScreens> {
  final _search = TextEditingController();
  final _permits = _samplePermits();
  String _filter = 'Semua';
  String _query = '';

  static const _filters = [
    'Semua',
    'Menunggu',
    'Aktif',
    'Akan berakhir',
    'Kedaluwarsa',
  ];

  List<_Permit> get _visible => _permits.where((permit) {
    final matchesStatus = switch (_filter) {
      'Menunggu' => permit.status == _Status.pending,
      'Aktif' => permit.status == _Status.active,
      'Akan berakhir' => permit.status == _Status.expiring,
      'Kedaluwarsa' => permit.status == _Status.expired,
      _ => true,
    };
    final text =
        '${permit.id} ${permit.category} ${permit.destination} ${permit.partner}'
            .toLowerCase();
    return matchesStatus && text.contains(_query);
  }).toList();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _navigate(int index) {
    final page = switch (index) {
      0 => const DashboardAdminScreens(),
      1 => const MitraAdminScreens(),
      2 => const PerizinanAdminScreens(),
      3 => const LaporanAdminScreens(),
      4 => const ProfilAdminScreens(),
      _ => null,
    };
    if (page == null || index == 2) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _openPermit(_Permit permit) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(permit.destination),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusBadge(permit.status),
            const SizedBox(height: 16),
            _detail('Nomor registrasi', permit.id),
            _detail('Kategori', permit.category),
            _detail('Mitra', permit.partner),
            _detail('Masa berlaku', permit.dates),
            _detail('Auditor', permit.auditor),
            const SizedBox(height: 8),
            Text(permit.note, style: const TextStyle(color: _muted)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
        if (permit.status == _Status.pending)
          FilledButton(
            onPressed: () {
              setState(() => permit.status = _Status.active);
              Navigator.pop(context);
              _message('${permit.id} ditandai siap setelah audit.');
            },
            child: const Text('Tandai diverifikasi'),
          ),
        if (permit.status == _Status.expiring)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _message(
                'Pengingat perpanjangan untuk ${permit.partner} disiapkan.',
              );
            },
            child: const Text('Kirim pengingat'),
          ),
      ],
    ),
  );

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 135,
          child: Text(label, style: const TextStyle(color: _muted)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Future<void> _addPermit() async {
    final form = GlobalKey<FormState>();
    final destination = TextEditingController();
    final partner = TextEditingController();
    final category = TextEditingController();
    final permit = await showDialog<_Permit>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrasi izin'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _input(destination, 'Nama wisata'),
                const SizedBox(height: 12),
                _input(partner, 'Nama mitra'),
                const SizedBox(height: 12),
                _input(category, 'Kategori wisata'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              Navigator.pop(
                context,
                _Permit(
                  'IZ-2026-${130 + _permits.length}',
                  category.text.trim(),
                  destination.text.trim(),
                  partner.text.trim(),
                  '11 Nov 2026 — Belum ditetapkan',
                  'Menunggu pemeriksaan dokumen perizinan.',
                  'Belum ditugaskan',
                  Icons.place_outlined,
                  const Color(0xFFE5EDFF),
                  _Status.pending,
                ),
              );
            },
            child: const Text('Tambah ke antrean'),
          ),
        ],
      ),
    );
    destination.dispose();
    partner.dispose();
    category.dispose();
    if (permit != null && mounted) {
      setState(() => _permits.insert(0, permit));
      _message('${permit.id} ditambahkan ke antrean audit.');
    }
  }

  Widget _input(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Wajib diisi' : null,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _page,
    body: SafeArea(
      child: Column(
        children: [
          _header(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 1100;
                return _content(desktop, constraints.maxWidth);
              },
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: AdminBottomNavigator(
      currentIndex: 2,
      onTap: _navigate,
    ),
  );

  Widget _header() => Container(
    height: 66,
    padding: const EdgeInsets.symmetric(horizontal: 28),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: _border)),
    ),
    child: Row(
      children: [
        Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 22),
        const SizedBox(width: 10),
        Text(
          'LOKATRIP ADMIN',
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: _blue,
          ),
        ),
        const Spacer(),
        AdminNotificationButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotifikasiAdminScreens()),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFFE8EEFF),
          child: Icon(Icons.person_outline, size: 19, color: _blue),
        ),
      ],
    ),
  );

  Widget _content(bool desktop, double maxWidth) {
    final pageWidth = maxWidth > 1320 ? 1320.0 : maxWidth;
    final padding = desktop ? 32.0 : 20.0;
    final cardWidth = pageWidth - padding * 2;
    final columns = cardWidth >= 1050 ? 2 : 1;
    final permitWidth = (cardWidth - 14 * (columns - 1)) / columns;
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(desktop),
              const SizedBox(height: 22),
              _summary(cardWidth),
              const SizedBox(height: 18),
              _searchBar(),
              const SizedBox(height: 10),
              _filterBar(),
              const SizedBox(height: 12),
              if (_visible.isEmpty)
                _emptyState()
              else
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final permit in _visible)
                      SizedBox(width: permitWidth, child: _permitCard(permit)),
                  ],
                ),
              const SizedBox(height: 16),
              _registrationBanner(),
              const SizedBox(height: 10),
              Text(
                'Data contoh untuk rancangan audit; belum terhubung ke backend.',
                style: GoogleFonts.manrope(fontSize: 11, color: _muted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(bool desktop) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit & verifikasi izin',
              style: GoogleFonts.manrope(
                fontSize: desktop ? 27 : 23,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            Text(
              'Kelola izin operasional mitra wisata daerah',
              style: GoogleFonts.manrope(fontSize: 13, color: _muted),
            ),
          ],
        ),
      ),
      _badge('SLA 98.4%', _green, const Color(0xFFDDF5E9)),
    ],
  );

  Widget _summary(double width) {
    final columns = width >= 980
        ? 4
        : width >= 540
        ? 2
        : 1;
    final itemWidth = (width - 12 * (columns - 1)) / columns;
    const items = [
      ('Aktif', '120', 'Kepatuhan SLA 94%', Icons.verified_outlined, _green),
      ('Menunggu', '12', '3 prioritas', Icons.hourglass_top, Color(0xFF1681B0)),
      (
        'Akan berakhir',
        '8',
        'Dalam 30 hari',
        Icons.warning_amber_rounded,
        _blue,
      ),
      ('Kedaluwarsa', '3', 'Tindakan diperlukan', Icons.cancel_outlined, _red),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final item in items)
          SizedBox(
            width: itemWidth,
            child: _SummaryCard(item.$1, item.$2, item.$3, item.$4, item.$5),
          ),
      ],
    );
  }

  Widget _searchBar() => TextField(
    controller: _search,
    onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
    decoration: InputDecoration(
      hintText: 'Cari nomor registrasi, mitra, atau wisata...',
      prefixIcon: const Icon(Icons.search, color: _muted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
    ),
  );

  Widget _filterBar() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final filter in _filters)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$filter (${_filterCount(filter)})'),
              selected: _filter == filter,
              onSelected: (_) => setState(() => _filter = filter),
              selectedColor: _blue,
              backgroundColor: Colors.white,
              side: BorderSide(color: _filter == filter ? _blue : _border),
              labelStyle: GoogleFonts.manrope(
                color: _filter == filter ? Colors.white : _ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              showCheckmark: false,
            ),
          ),
      ],
    ),
  );

  int _filterCount(String label) {
    if (label == 'Semua') return _permits.length;
    final status = switch (label) {
      'Menunggu' => _Status.pending,
      'Aktif' => _Status.active,
      'Akan berakhir' => _Status.expiring,
      _ => _Status.expired,
    };
    return _permits.where((permit) => permit.status == status).length;
  }

  Widget _permitCard(_Permit permit) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: () => _openPermit(permit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  permit.id,
                  style: GoogleFonts.manrope(
                    color: _blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '· ${permit.category}',
                    style: GoogleFonts.manrope(color: _muted, fontSize: 10),
                  ),
                ),
                _statusBadge(permit.status),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: permit.iconBackground,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(permit.icon, color: _blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        permit.destination,
                        style: GoogleFonts.manrope(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        permit.partner,
                        style: GoogleFonts.manrope(fontSize: 11, color: _muted),
                      ),
                      Text(
                        permit.dates,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: permit.status == _Status.expired
                              ? _red
                              : _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: Text(
                    permit.status == _Status.expiring
                        ? 'Perlu perpanjangan'
                        : permit.status == _Status.expired
                        ? 'Status operasional dibekukan'
                        : permit.auditor,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: permit.status == _Status.expired ? _red : _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (permit.status == _Status.expiring)
                  TextButton(
                    onPressed: () => _message(
                      'Pengingat perpanjangan untuk ${permit.partner} disiapkan.',
                    ),
                    child: const Text('Kirim pengingat'),
                  ),
                Icon(
                  Icons.arrow_forward,
                  color: _statusColors[permit.status],
                  size: 19,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _emptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: const Column(
      children: [
        Icon(Icons.search_off, color: _muted),
        SizedBox(height: 8),
        Text('Tidak ada izin yang cocok'),
        Text('Ubah pencarian atau pilih status lain.'),
      ],
    ),
  );

  Widget _registrationBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F0FF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          child: Icon(Icons.post_add_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrasi izin baru?',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              Text(
                'Tambahkan mitra ke antrean pemeriksaan.',
                style: GoogleFonts.manrope(fontSize: 11, color: _muted),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: _addPermit,
          icon: const Icon(Icons.add, size: 17),
          label: const Text('Tambah izin'),
        ),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  final String title, value, detail;
  final IconData icon;
  final Color color;

  const _SummaryCard(
    this.title,
    this.value,
    this.detail,
    this.icon,
    this.color,
  );

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 120),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Icon(icon, size: 19, color: color),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: title == 'Kedaluwarsa' ? _red : _ink,
          ),
        ),
        Text(
          detail,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _statusBadge(_Status status) {
  final (label, color, background) = switch (status) {
    _Status.active => ('AKTIF', _green, const Color(0xFFDDF5E9)),
    _Status.pending => (
      'MENUNGGU AUDIT',
      const Color(0xFF08749B),
      const Color(0xFFD9F0FF),
    ),
    _Status.expiring => ('AKAN BERAKHIR', _blue, const Color(0xFFE3EAFF)),
    _Status.expired => ('KEDALUWARSA', _red, const Color(0xFFFFE1DF)),
  };
  return _badge(label, color, background);
}

const _statusColors = {
  _Status.active: _green,
  _Status.pending: Color(0xFF08749B),
  _Status.expiring: _blue,
  _Status.expired: _red,
};

Widget _badge(String label, Color color, Color background) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
  decoration: BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(99),
  ),
  child: Text(
    label,
    style: GoogleFonts.manrope(
      color: color,
      fontSize: 9,
      fontWeight: FontWeight.w800,
    ),
  ),
);

List<_Permit> _samplePermits() => [
  _Permit(
    'IZ-2026-00128',
    'Ekraf & Wisata',
    'Gunung Bromo Adventure',
    'CV Pesona Nusantara',
    '16 Sep 2026 — 16 Sep 2027',
    'Dokumen dasar tercatat; menunggu audit lapangan.',
    'Kemenparekraf RI terverifikasi',
    Icons.landscape_outlined,
    const Color(0xFFE6ECF9),
    _Status.pending,
  ),
  _Permit(
    'IZ-2026-00114',
    'Rekreasi Alam',
    'Batu Adventure Park',
    'CV Alam Raya',
    '10 Jul 2026 — 10 Jul 2027',
    'Polis asuransi pengunjung perlu diperpanjang.',
    'Dokumen diperbarui 2 hari lalu',
    Icons.forest_outlined,
    const Color(0xFFE3F1E8),
    _Status.expiring,
  ),
  _Permit(
    'IZ-2026-00129',
    'Ekowisata',
    'Coban Talun Wisata',
    'PT Jelajah Indonesia',
    '18 Sep 2026 — 18 Sep 2027',
    'Berkas lengkap dan masuk antrean audit lapangan.',
    'Auditor: Ir. Budi Santoso',
    Icons.waterfall_chart_outlined,
    const Color(0xFFDDF1EA),
    _Status.pending,
  ),
  _Permit(
    'IZ-2025-00042',
    'Wahana Air',
    'Waterpark Tirta Safari',
    'CV Tirta Lestari',
    '15 Agu 2025 — 15 Agu 2026',
    'Izin melewati masa berlaku dan perlu pemeriksaan ulang.',
    'Status operasional dibekukan',
    Icons.pool_outlined,
    const Color(0xFFDCEFFA),
    _Status.expired,
  ),
  _Permit(
    'IZ-2026-00076',
    'Wisata Bahari',
    'Liveaboard Phinisi Komodo',
    'PT Bajo Bahari Adventure',
    '02 Mei 2026 — 02 Mei 2027',
    'Izin aktif; dokumen keselamatan tercatat.',
    'Dokumen terverifikasi',
    Icons.sailing_outlined,
    const Color(0xFFDDF1F5),
    _Status.active,
  ),
];
