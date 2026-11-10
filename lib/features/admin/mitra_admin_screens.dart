import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/admin_bottom_navigator.dart';
import '../../widgets/admin_notification_button.dart';
import 'dashboard_admin_screens.dart';
import 'laporan_admin_screens.dart';
import 'notifikasi_admin_screens.dart';
import 'perizinan_admin_screens.dart';
import 'profil_screens.dart';

const _mitraNavy = Color(0xFF10243A);
const _mitraBlue = Color(0xFF1748D1);
const _mitraMuted = Color(0xFF50566A);
const _mitraPage = Color(0xFFF7F8FD);
const _mitraBorder = Color(0xFFE9ECF3);

enum _MitraStatus { active, pending, rejected, suspended }

class _MitraData {
  final String id;
  final String nama;
  final String destinasi;
  final String lokasi;
  final String kategori;
  final _MitraStatus status;
  final IconData fotoIcon;
  final Color fotoColor;
  final String gabung;
  final String transaksi;
  final String legalitas;
  final String? alasan;
  final String? dokumen;
  final String? tenggat;
  final bool ditampilkanDiBeranda;
  final String catatanAdmin;
  final List<_MitraHistory> riwayat;
  final bool diarsipkan;

  const _MitraData({
    required this.id,
    required this.nama,
    required this.destinasi,
    required this.lokasi,
    required this.kategori,
    required this.status,
    required this.fotoIcon,
    required this.fotoColor,
    this.gabung = '',
    this.transaksi = '',
    this.legalitas = '',
    this.alasan,
    this.dokumen,
    this.tenggat,
    this.ditampilkanDiBeranda = true,
    this.catatanAdmin = '',
    this.riwayat = const [],
    this.diarsipkan = false,
  });

  _MitraData copyWith({
    _MitraStatus? status,
    bool? ditampilkanDiBeranda,
    String? catatanAdmin,
    List<_MitraHistory>? riwayat,
    bool? diarsipkan,
  }) {
    return _MitraData(
      id: id,
      nama: nama,
      destinasi: destinasi,
      lokasi: lokasi,
      kategori: kategori,
      status: status ?? this.status,
      fotoIcon: fotoIcon,
      fotoColor: fotoColor,
      gabung: gabung,
      transaksi: transaksi,
      legalitas: legalitas,
      alasan: alasan,
      dokumen: dokumen,
      tenggat: tenggat,
      ditampilkanDiBeranda: ditampilkanDiBeranda ?? this.ditampilkanDiBeranda,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      riwayat: riwayat ?? this.riwayat,
      diarsipkan: diarsipkan ?? this.diarsipkan,
    );
  }
}

const _mitraData = [
  _MitraData(
    id: 'MIT-00128',
    nama: 'CV Pesona Nusantara',
    destinasi: 'Gunung Bromo Adventure',
    lokasi: 'Kab. Probolinggo',
    kategori: 'Alam',
    status: _MitraStatus.active,
    fotoIcon: Icons.landscape_rounded,
    fotoColor: Color(0xFFC9A87B),
    gabung: "12 Agu '26",
    transaksi: '1.482 Tiket',
    legalitas: 'Sep 2027',
  ),
  _MitraData(
    id: 'MIT-00114',
    nama: 'CV Alam Raya',
    destinasi: 'Batu Adventure Park',
    lokasi: 'Kota Batu, Malang',
    kategori: 'Alam',
    status: _MitraStatus.active,
    fotoIcon: Icons.forest_rounded,
    fotoColor: Color(0xFF8FBB91),
    gabung: "10 Jul '26",
    transaksi: '890 Tiket',
    legalitas: 'Valid',
  ),
  _MitraData(
    id: 'MIT-00076',
    nama: 'PT Bajo Bahari Adventure',
    destinasi: 'Liveaboard Phinisi Komodo',
    lokasi: 'Labuan Bajo, NTT',
    kategori: 'Bahari',
    status: _MitraStatus.active,
    fotoIcon: Icons.sailing_rounded,
    fotoColor: Color(0xFF6FB8D2),
    gabung: "02 Mei '26",
    transaksi: '2.310 Tiket',
    legalitas: 'Valid',
  ),
  _MitraData(
    id: 'MIT-00062',
    nama: 'Koperasi Wisata Dieng Mandiri',
    destinasi: 'Kawah Sikidang & Telaga Warna',
    lokasi: 'Wonosobo, Jawa Tengah',
    kategori: 'Alam',
    status: _MitraStatus.active,
    fotoIcon: Icons.terrain_rounded,
    fotoColor: Color(0xFF7FAF9A),
    gabung: "18 Jan '26",
    transaksi: '3.120 Tiket',
    legalitas: 'Valid',
  ),
  _MitraData(
    id: 'MIT-00129',
    nama: 'PT Jelajah Indonesia',
    destinasi: 'Coban Talun Wisata',
    lokasi: 'Kota Batu, Jawa Timur',
    kategori: 'Alam',
    status: _MitraStatus.pending,
    fotoIcon: Icons.waterfall_chart_rounded,
    fotoColor: Color(0xFF7DB9A8),
    dokumen: '3/4 Berkas',
    tenggat: 'SLA Sisa 4 Jam',
  ),
  _MitraData(
    id: 'MIT-00128',
    nama: 'CV Pesona Nusantara',
    destinasi: 'Gunung Bromo Adventure',
    lokasi: 'Jawa Timur',
    kategori: 'Alam',
    status: _MitraStatus.pending,
    fotoIcon: Icons.landscape_rounded,
    fotoColor: Color(0xFFC9A87B),
    dokumen: '4/4 Berkas',
    tenggat: 'SLA Sisa 14 Jam',
  ),
  _MitraData(
    id: 'MIT-00135',
    nama: 'Pokdarwis Desa Sade',
    destinasi: 'Sade Cultural Tour',
    lokasi: 'NTB',
    kategori: 'Budaya',
    status: _MitraStatus.pending,
    fotoIcon: Icons.holiday_village_rounded,
    fotoColor: Color(0xFFD8B98E),
    dokumen: 'KTP, NIB, & Surat Desa Lengkap',
    tenggat: 'SLA Sisa 19 Jam',
  ),
  _MitraData(
    id: 'MIT-00140',
    nama: 'PT Bahari Nusa Wisata',
    destinasi: 'Labuan Bajo Phinisi',
    lokasi: 'NTT',
    kategori: 'Bahari',
    status: _MitraStatus.pending,
    fotoIcon: Icons.sailing_rounded,
    fotoColor: Color(0xFF6FB8D2),
    dokumen: 'Revisi dokumen dikirim',
    tenggat: 'Prioritas Tinggi',
  ),
  _MitraData(
    id: 'MIT-00087',
    nama: 'Waterpark Tirta Safari',
    destinasi: 'Wahana Air',
    lokasi: 'CV Tirta Lestari',
    kategori: 'Wahana Air',
    status: _MitraStatus.rejected,
    fotoIcon: Icons.pool_rounded,
    fotoColor: Color(0xFF62B6D7),
    alasan:
        'Sertifikat Uji Kelayakan Wahana K3 Depnaker kedaluwarsa & tidak ada asuransi pengunjung komprehensif.',
  ),
  _MitraData(
    id: 'MIT-00091',
    nama: 'Offroad Extreme Cisarua',
    destinasi: 'Petualangan',
    lokasi: 'PT Jelajah Rimba Liar',
    kategori: 'Petualangan',
    status: _MitraStatus.rejected,
    fotoIcon: Icons.directions_car_filled_rounded,
    fotoColor: Color(0xFF8D9A73),
    alasan:
        'Tidak memiliki izin operasional pemda setempat dan NIB tidak sesuai KBLI pariwisata petualangan berisiko tinggi.',
  ),
  _MitraData(
    id: 'MIT-00095',
    nama: 'Paralayang Merapi Tour',
    destinasi: 'Olahraga Ekstrem',
    lokasi: 'Pokdarwis Bukit Hijau',
    kategori: 'Petualangan',
    status: _MitraStatus.rejected,
    fotoIcon: Icons.paragliding_rounded,
    fotoColor: Color(0xFFB7A58A),
    alasan:
        'Pilot paralayang belum memiliki lisensi FASI aktif tandem dan polis asuransi evakuasi udara nihil.',
  ),
];

final _mitraDataState = List<_MitraData>.of(_mitraData);
const _mitraStorageKey = 'admin_mitra_records_v1';

class MitraAdminScreens extends StatefulWidget {
  const MitraAdminScreens({super.key});

  @override
  State<MitraAdminScreens> createState() => _MitraAdminScreensState();
}

class _MitraAdminScreensState extends State<MitraAdminScreens> {
  final _searchController = TextEditingController();
  int _selectedTab = 1;
  String _selectedCategory = 'Semua kategori';
  bool _newestFirst = true;

  static const _tabs = [
    'Semua',
    'Aktif',
    'Menunggu',
    'Ditolak',
    'Ditangguhkan',
  ];

  @override
  void initState() {
    super.initState();
    _loadMitraState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigate(int index) {
    if (index == 1) return;
    final Widget destination = switch (index) {
      0 => const DashboardAdminScreens(),
      2 => const PerizinanAdminScreens(),
      3 => const LaporanAdminScreens(),
      4 => const ProfilAdminScreens(),
      _ => const MitraAdminScreens(),
    };
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => destination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  List<_MitraData> get _filteredMitra {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _mitraDataState.where((mitra) {
      if (mitra.diarsipkan) return false;
      final matchesTab =
          _selectedTab == 0 ||
          switch (_selectedTab) {
            1 => mitra.status == _MitraStatus.active,
            2 => mitra.status == _MitraStatus.pending,
            3 => mitra.status == _MitraStatus.rejected,
            _ => mitra.status == _MitraStatus.suspended,
          };
      final matchesQuery =
          query.isEmpty ||
          '${mitra.id} ${mitra.nama} ${mitra.destinasi} ${mitra.lokasi}'
              .toLowerCase()
              .contains(query);
      final matchesCategory =
          _selectedCategory == 'Semua kategori' ||
          mitra.kategori == _selectedCategory;
      return matchesTab && matchesQuery && matchesCategory;
    }).toList();
    if (!_newestFirst && _selectedTab == 1) {
      return filtered.reversed.toList();
    }
    return filtered;
  }

  String _tabCount(int tab) {
    const baseline = [148, 128, 12, 8, 0];
    bool matches(_MitraData item) {
      if (item.diarsipkan) return false;
      if (tab == 0) return true;
      return item.status ==
          switch (tab) {
            1 => _MitraStatus.active,
            2 => _MitraStatus.pending,
            3 => _MitraStatus.rejected,
            _ => _MitraStatus.suspended,
          };
    }

    final originalCount = _mitraData.where(matches).length;
    final updatedCount = _mitraDataState.where(matches).length;
    return '${baseline[tab] + updatedCount - originalCount}';
  }

  Future<void> _loadMitraState() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_mitraStorageKey);
      if (saved == null) return;
      final decoded = jsonDecode(saved);
      if (decoded is! List) {
        throw const FormatException('Format data mitra tidak valid.');
      }

      final updates = <int, _MitraData>{};
      for (final entry in decoded) {
        if (entry is! Map ||
            entry['index'] is! int ||
            entry['index'] < 0 ||
            entry['index'] >= _mitraData.length) {
          throw const FormatException('Data perubahan mitra tidak valid.');
        }
        final index = entry['index'] as int;
        final base = _mitraData[index];
        final statusName = entry['status'];
        final status = _MitraStatus.values.firstWhere(
          (value) => value.name == statusName,
          orElse: () =>
              throw const FormatException('Status mitra tidak valid.'),
        );
        final historyData = entry['riwayat'];
        if (historyData is! List) {
          throw const FormatException('Riwayat mitra tidak valid.');
        }
        final history = historyData.map((item) {
          if (item is! Map ||
              item['title'] is! String ||
              item['description'] is! String ||
              item['date'] is! String) {
            throw const FormatException('Catatan riwayat mitra tidak valid.');
          }
          return _MitraHistory(
            title: item['title'] as String,
            description: item['description'] as String,
            date: item['date'] as String,
            icon: Icons.history_rounded,
          );
        }).toList();

        updates[index] = base.copyWith(
          status: status,
          ditampilkanDiBeranda: entry['ditampilkanDiBeranda'] is bool
              ? entry['ditampilkanDiBeranda'] as bool
              : base.ditampilkanDiBeranda,
          catatanAdmin: entry['catatanAdmin'] is String
              ? entry['catatanAdmin'] as String
              : base.catatanAdmin,
          riwayat: history,
          diarsipkan: entry['diarsipkan'] is bool
              ? entry['diarsipkan'] as bool
              : false,
        );
      }

      if (!mounted) return;
      setState(() {
        for (final update in updates.entries) {
          _mitraDataState[update.key] = update.value;
        }
      });
    } on FormatException catch (error) {
      _showPersistenceError('Data mitra tersimpan tidak dapat dibaca: $error');
    } on Exception catch (error) {
      _showPersistenceError('Gagal memuat data mitra tersimpan: $error');
    }
  }

  Future<void> _persistMitraState() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final records = <Map<String, Object>>[];
      for (var index = 0; index < _mitraDataState.length; index++) {
        final item = _mitraDataState[index];
        final base = _mitraData[index];
        if (item.status == base.status &&
            item.ditampilkanDiBeranda == base.ditampilkanDiBeranda &&
            item.catatanAdmin == base.catatanAdmin &&
            item.riwayat.isEmpty &&
            !item.diarsipkan) {
          continue;
        }
        records.add({
          'index': index,
          'status': item.status.name,
          'ditampilkanDiBeranda': item.ditampilkanDiBeranda,
          'catatanAdmin': item.catatanAdmin,
          'diarsipkan': item.diarsipkan,
          'riwayat': item.riwayat
              .map(
                (history) => {
                  'title': history.title,
                  'description': history.description,
                  'date': history.date,
                },
              )
              .toList(),
        });
      }
      final saved = await preferences.setString(
        _mitraStorageKey,
        jsonEncode(records),
      );
      if (!saved && mounted) {
        _showPersistenceError('Perubahan mitra gagal disimpan.');
      }
    } on Exception catch (error) {
      _showPersistenceError('Gagal menyimpan perubahan mitra: $error');
    }
  }

  void _showPersistenceError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final mitra = _filteredMitra;
    return Scaffold(
      backgroundColor: _mitraPage,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _MitraHeader(),
            _buildSearchRow(),
            _buildTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  if (_selectedTab == 2) ...[
                    const _PendingSummary(),
                    const SizedBox(height: 12),
                  ] else if (_selectedTab == 3) ...[
                    const _RejectedNotice(),
                    const SizedBox(height: 12),
                  ] else if (_selectedTab == 1) ...[
                    _ActiveSummary(
                      count:
                          _searchController.text.isEmpty &&
                              _selectedCategory == 'Semua kategori'
                          ? _tabCount(1)
                          : '${mitra.length}',
                      newestFirst: _newestFirst,
                      onSort: () =>
                          setState(() => _newestFirst = !_newestFirst),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (mitra.isEmpty)
                    const _EmptySearchResult()
                  else
                    ...mitra.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: switch (item.status) {
                          _MitraStatus.active => _ActiveMitraCard(
                            mitra: item,
                            onTap: () => _showMitraDetails(item),
                          ),
                          _MitraStatus.pending => _PendingMitraCard(
                            mitra: item,
                            onTap: () => _showMitraDetails(item),
                          ),
                          _MitraStatus.rejected => _RejectedMitraCard(
                            mitra: item,
                            onTap: () => _showMitraDetails(item),
                            onArchive: () => _archiveMitra(item),
                          ),
                          _MitraStatus.suspended => _ActiveMitraCard(
                            mitra: item,
                            onTap: () => _showMitraDetails(item),
                          ),
                        },
                      ),
                    ),
                  if (_selectedTab == 1 || _selectedTab == 0) ...[
                    const SizedBox(height: 2),
                    _ExportCard(onExport: _showExportMessage),
                  ],
                  if (_selectedTab == 2) ...[
                    const SizedBox(height: 4),
                    const _OperationalStandard(),
                  ],
                  if (_selectedTab == 3) ...[
                    const SizedBox(height: 8),
                    const _RejectedFooter(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNavigator(
        currentIndex: 1,
        onTap: _navigate,
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _mitraBorder, width: 0.6),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.manrope(fontSize: 12, color: _mitraNavy),
                decoration: InputDecoration(
                  hintText: 'Cari nama mitra, destinasi, atau ID...',
                  hintStyle: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF85899A),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: _mitraMuted,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close, size: 16),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _showFilters,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.tune_rounded, color: _mitraBlue, size: 20),
                    if (_selectedCategory != 'Semua kategori')
                      Positioned(
                        top: 8,
                        right: 9,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: _mitraBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedTab;
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? _mitraBlue : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? _mitraBlue : _mitraBorder,
                  width: 0.6,
                ),
              ),
              child: Row(
                children: [
                  if (selected) ...[
                    const Icon(Icons.circle, size: 7, color: Colors.white),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    _tabs[index],
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : _mitraMuted,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _tabCount(index),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFF85899A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilters() {
    const categories = [
      'Semua kategori',
      'Alam',
      'Bahari',
      'Budaya',
      'Petualangan',
      'Wahana Air',
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DAE2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Filter Kategori Mitra',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _mitraNavy,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final selected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                      Navigator.pop(context);
                    },
                    labelStyle: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _mitraMuted,
                    ),
                    selectedColor: _mitraBlue,
                    backgroundColor: _mitraPage,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMitraDetails(_MitraData mitra) async {
    final updatedMitra = await Navigator.push<_MitraData>(
      context,
      MaterialPageRoute(builder: (_) => _MitraDetailAdminScreens(mitra: mitra)),
    );
    if (updatedMitra == null || !mounted) return;
    final index = _mitraDataState.indexWhere((item) => identical(item, mitra));
    if (index >= 0) {
      setState(() => _mitraDataState[index] = updatedMitra);
      await _persistMitraState();
    }
  }

  Future<void> _archiveMitra(_MitraData mitra) async {
    final index = _mitraDataState.indexWhere((item) => identical(item, mitra));
    if (index < 0) return;
    setState(() {
      _mitraDataState[index] = mitra.copyWith(diarsipkan: true);
    });
    await _persistMitraState();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${mitra.nama} diarsipkan.')));
  }

  void _showExportMessage(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rekap mitra format $format sedang disiapkan.')),
    );
  }
}

class _MitraHeader extends StatelessWidget {
  const _MitraHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _mitraPage,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Row(
        children: [
          Image.asset('assets/images/LokaTrip-logo-no-van.png', height: 14),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOKATRIP ADMIN',
                style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _mitraBlue,
                  letterSpacing: 0.7,
                ),
              ),
              Text(
                'Mitra',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: _mitraNavy,
                ),
              ),
            ],
          ),
          const Spacer(),
          AdminNotificationButton(
            color: _mitraNavy,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotifikasiAdminScreens()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSummary extends StatelessWidget {
  final String count;
  final bool newestFirst;
  final VoidCallback onSort;

  const _ActiveSummary({
    required this.count,
    required this.newestFirst,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Mitra',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _mitraNavy,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFF047857)),
                    const SizedBox(width: 4),
                    Text(
                      'Kepatuhan 98.4%',
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onSort,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF0F3FC),
              foregroundColor: _mitraMuted,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            iconAlignment: IconAlignment.end,
            icon: Icon(
              newestFirst
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 14,
            ),
            label: Text(
              newestFirst ? 'Terbaru' : 'Terlama',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveMitraCard extends StatelessWidget {
  final _MitraData mitra;
  final VoidCallback onTap;

  const _ActiveMitraCard({required this.mitra, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                _MitraPhoto(mitra: mitra),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID: ${mitra.id}',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _mitraMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mitra.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _mitraNavy,
                        ),
                      ),
                      Text(
                        mitra.destinasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _mitraBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _StatusPill(
                  label: mitra.status == _MitraStatus.suspended
                      ? 'Ditangguhkan'
                      : 'Aktif',
                  textColor: mitra.status == _MitraStatus.suspended
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF065F46),
                  background: mitra.status == _MitraStatus.suspended
                      ? const Color(0xFFFFD8D5)
                      : const Color(0xFF71F0C0),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  _Metric(label: 'Bergabung', value: mitra.gabung),
                  _Metric(label: 'Transaksi', value: mitra.transaksi),
                  _Metric(
                    label: 'Legalitas',
                    value: mitra.legalitas,
                    valid: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: _mitraBlue,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    mitra.lokasi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _mitraMuted,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFDDE8FF),
                    foregroundColor: _mitraBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Kelola Mitra',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 15),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingSummary extends StatelessWidget {
  const _PendingSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE3EAFF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.pending_actions_rounded, color: _mitraBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '12 Mitra Menunggu',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _mitraNavy,
                  ),
                ),
                Text(
                  'Memerlukan audit legalitas berkas',
                  style: GoogleFonts.manrope(fontSize: 10, color: _mitraMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const _StatusPill(
                label: '◷ TARGET SLA',
                textColor: _mitraBlue,
                background: Color(0xFFE9F0FF),
              ),
              const SizedBox(height: 3),
              Text(
                'Rata-rata 24 Jam',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _mitraNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingMitraCard extends StatelessWidget {
  final _MitraData mitra;
  final VoidCallback onTap;

  const _PendingMitraCard({required this.mitra, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final revision = mitra.dokumen?.contains('Revisi') ?? false;
    final complete = mitra.dokumen?.startsWith('4/') ?? false;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MitraPhoto(mitra: mitra, size: 48),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mitra.id}  •  ${mitra.destinasi}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF08709B),
                        ),
                      ),
                      Text(
                        mitra.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _mitraNavy,
                        ),
                      ),
                      Text(
                        'PIC: ${_pendingPic(mitra)} · ${mitra.lokasi}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: _mitraMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                _StatusPill(
                  label: revision ? 'Revisi Terkirim' : 'Menunggu',
                  textColor: revision ? const Color(0xFF0369A1) : _mitraBlue,
                  background: revision
                      ? const Color(0xFFD7F0FF)
                      : const Color(0xFFE5EDFF),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    complete
                        ? Icons.check_circle_outline
                        : Icons.description_outlined,
                    size: 14,
                    color: complete
                        ? const Color(0xFF047857)
                        : const Color(0xFF5B6070),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      complete
                          ? 'Dokumen Lengkap Siap Validasi'
                          : mitra.dokumen!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _mitraMuted,
                      ),
                    ),
                  ),
                  if (mitra.dokumen!.contains('/'))
                    Text(
                      mitra.dokumen!,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: complete ? const Color(0xFF047857) : _mitraNavy,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  revision
                      ? Icons.notifications_active_outlined
                      : Icons.schedule,
                  size: 14,
                  color: revision ? _mitraBlue : const Color(0xFF0284C7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mitra.tenggat!,
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: revision
                              ? _mitraBlue
                              : const Color(0xFFB91C1C),
                        ),
                      ),
                      Text(
                        revision
                            ? 'Revisi diajukan ulang'
                            : 'Batas hari ini 17:00',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          color: _mitraMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: revision
                        ? const Color(0xFFE3ECFF)
                        : _mitraBlue,
                    foregroundColor: revision ? _mitraNavy : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        revision ? 'Tinjau Revisi' : 'Verifikasi Berkas',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.arrow_forward_rounded, size: 13),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _pendingPic(_MitraData item) {
    return switch (item.id) {
      'MIT-00129' => 'Hendra Setiawan',
      'MIT-00128' => 'Ratih Pratiwi',
      'MIT-00135' => 'Lalu Wirasanjaya',
      _ => 'Dimas',
    };
  }
}

class _RejectedNotice extends StatelessWidget {
  const _RejectedNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE8E8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFCC2020),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi Kepatuhan & Legalitas',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '5 pengajuan ditolak karena ketidaksesuaian dokumen legalitas, izin keselamatan wahana, atau ketidakvalidan data penanggung jawab.',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    height: 1.45,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectedMitraCard extends StatelessWidget {
  final _MitraData mitra;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  const _RejectedMitraCard({
    required this.mitra,
    required this.onTap,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Row(
              children: [
                _MitraPhoto(mitra: mitra, size: 48),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mitra.id}  •  ${mitra.kategori}',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF777D8E),
                        ),
                      ),
                      Text(
                        mitra.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _mitraNavy,
                        ),
                      ),
                      Text(
                        mitra.lokasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: _mitraMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const _StatusPill(
                  label: 'Ditolak',
                  textColor: Color(0xFFB91C1C),
                  background: Color(0xFFFFD8D5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 13,
                        color: Color(0xFFB91C1C),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Alasan Diskualifikasi',
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                      Text(
                        _rejectionDate(mitra.id),
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF85899A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mitra.alasan!,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      height: 1.45,
                      color: const Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                if (mitra.id == 'MIT-00087')
                  const Expanded(
                    child: _SmallAction(
                      icon: Icons.folder_off_outlined,
                      label: 'Berkas Dikunci',
                      color: Color(0xFF85899A),
                    ),
                  )
                else
                  Expanded(
                    child: InkWell(
                      onTap: onTap,
                      child: const _SmallAction(
                        icon: Icons.edit_document,
                        label: 'Buka Banding',
                        color: _mitraBlue,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: onArchive,
                  style: TextButton.styleFrom(
                    foregroundColor: _mitraMuted,
                    backgroundColor: const Color(0xFFF0F2F8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    'Arsipkan',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: _mitraBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Detail',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 13),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _rejectionDate(String id) {
    return switch (id) {
      'MIT-00087' => '28 Agu 2026',
      'MIT-00091' => '14 Agu 2026',
      _ => '03 Jul 2026',
    };
  }
}

class _OperationalStandard extends StatelessWidget {
  const _OperationalStandard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _mitraBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standar Operasional LokaTrip',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _mitraNavy,
                  ),
                ),
                Text(
                  'Semua pengajuan mitra baru dan pembaruan dokumen wajib diverifikasi dalam batas 1×24 jam kerja demi menjaga kepatuhan legalitas turis & asuransi perjalanan.',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    height: 1.45,
                    color: _mitraMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectedFooter extends StatelessWidget {
  const _RejectedFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 16,
                color: Color(0xFF777D8E),
              ),
              const SizedBox(width: 5),
              Text(
                'Audit Standar Keselamatan LokaTrip',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF777D8E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Mitra yang ditolak dapat mengajukan dokumen revisi maksimal 30 hari kalender sejak surat keputusan diterbitkan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 10,
              height: 1.4,
              color: _mitraMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final ValueChanged<String> onExport;

  const _ExportCard({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE3EAFF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: _mitraBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unduh Rekap Mitra Aktif',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _mitraNavy,
                  ),
                ),
                Text(
                  'Format PDF / XLS • Laporan',
                  style: GoogleFonts.manrope(fontSize: 10, color: _mitraMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _ExportButton(label: 'PDF', onPressed: () => onExport('PDF')),
          const SizedBox(width: 5),
          _ExportButton(
            label: 'XLS',
            primary: true,
            onPressed: () => onExport('XLS'),
          ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: primary ? _mitraBlue : const Color(0xFFF0F3FC),
        foregroundColor: primary ? Colors.white : _mitraBlue,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Row(
        children: [
          Icon(
            label == 'PDF' ? Icons.picture_as_pdf_outlined : Icons.table_chart,
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MitraPhoto extends StatelessWidget {
  final _MitraData mitra;
  final double size;

  const _MitraPhoto({required this.mitra, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: mitra.fotoColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(mitra.fotoIcon, color: Colors.white, size: size * 0.52),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool valid;

  const _Metric({required this.label, required this.value, this.valid = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: _mitraMuted,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (valid)
                const Icon(
                  Icons.verified_outlined,
                  size: 12,
                  color: Color(0xFF047857),
                ),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: valid ? const Color(0xFF065F46) : _mitraNavy,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color background;

  const _StatusPill({
    required this.label,
    required this.textColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SmallAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 36, color: _mitraMuted),
          const SizedBox(height: 8),
          Text(
            'Mitra tidak ditemukan',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _mitraNavy,
            ),
          ),
          Text(
            'Coba ubah kata kunci atau filter.',
            style: GoogleFonts.manrope(fontSize: 11, color: _mitraMuted),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: _mitraBorder, width: 0.6),
  );
}

class _MitraDetailAdminScreens extends StatefulWidget {
  final _MitraData mitra;

  const _MitraDetailAdminScreens({required this.mitra});

  @override
  State<_MitraDetailAdminScreens> createState() =>
      _MitraDetailAdminScreensState();
}

class _MitraDetailAdminScreensState extends State<_MitraDetailAdminScreens> {
  late _MitraStatus _status;
  late bool _ditampilkanDiBeranda;
  late final TextEditingController _catatanController;
  late final List<_MitraHistory> _history;

  @override
  void initState() {
    super.initState();
    _status = widget.mitra.status;
    _ditampilkanDiBeranda = widget.mitra.ditampilkanDiBeranda;
    _catatanController = TextEditingController(text: widget.mitra.catatanAdmin);
    _history = widget.mitra.riwayat.isNotEmpty
        ? List.of(widget.mitra.riwayat)
        : _initialHistory(widget.mitra);
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  List<_MitraHistory> _initialHistory(_MitraData mitra) {
    if (mitra.status == _MitraStatus.pending) {
      return [
        _MitraHistory(
          title: 'Pengajuan Mitra Diterima',
          description: 'Berkas masuk ke antrean verifikasi',
          date: '16 Sep 2026',
          icon: Icons.assignment_outlined,
        ),
        _MitraHistory(
          title: 'Dokumen Diperiksa',
          description: mitra.dokumen ?? 'Menunggu pemeriksaan admin',
          date: '15 Sep 2026',
          icon: Icons.description_outlined,
        ),
      ];
    }
    if (mitra.status == _MitraStatus.rejected) {
      return [
        _MitraHistory(
          title: 'Pengajuan Ditolak',
          description: mitra.alasan ?? 'Berkas belum memenuhi ketentuan',
          date: '16 Sep 2026',
          icon: Icons.block_outlined,
        ),
        _MitraHistory(
          title: 'Verifikasi Legalitas',
          description: 'Dokumen perlu diperbaiki',
          date: '10 Sep 2026',
          icon: Icons.verified_outlined,
        ),
      ];
    }
    return [
      _MitraHistory(
        title: _statusTitle(_status),
        description: _statusDescription(_status),
        date: '16 Sep 2026',
        icon: Icons.check_rounded,
      ),
      _MitraHistory(
        title: 'Verifikasi Berkas Disetujui',
        description: 'Dokumen usaha lengkap',
        date: '10 Sep 2026',
        icon: Icons.verified_outlined,
      ),
    ];
  }

  String _statusTitle(_MitraStatus status) => switch (status) {
    _MitraStatus.active => 'Status Diaktifkan',
    _MitraStatus.pending => 'Pengajuan Menunggu',
    _MitraStatus.rejected => 'Pengajuan Ditolak',
    _MitraStatus.suspended => 'Status Ditangguhkan',
  };

  String _statusDescription(_MitraStatus status) => switch (status) {
    _MitraStatus.active => 'Mitra dapat menerima pesanan wisatawan',
    _MitraStatus.pending => 'Menunggu verifikasi dokumen oleh admin',
    _MitraStatus.rejected => 'Pengajuan tidak memenuhi ketentuan',
    _MitraStatus.suspended => 'Operasional mitra dihentikan sementara',
  };

  void _save() {
    final oldStatus = widget.mitra.status;
    final settingsChanged =
        _ditampilkanDiBeranda != widget.mitra.ditampilkanDiBeranda ||
        _catatanController.text.trim() != widget.mitra.catatanAdmin;
    if (_status != oldStatus) {
      _history.insert(
        0,
        _MitraHistory(
          title: _statusTitle(_status),
          description: 'Status diperbarui oleh Admin',
          date: _todayLabel(),
          icon: _status == _MitraStatus.active
              ? Icons.check_rounded
              : Icons.edit_outlined,
        ),
      );
    } else if (settingsChanged) {
      _history.insert(
        0,
        _MitraHistory(
          title: 'Pengaturan Mitra Diperbarui',
          description: 'Catatan admin atau rekomendasi beranda diperbarui',
          date: _todayLabel(),
          icon: Icons.settings_outlined,
        ),
      );
    }
    Navigator.pop(
      context,
      widget.mitra.copyWith(
        status: _status,
        ditampilkanDiBeranda: _ditampilkanDiBeranda,
        catatanAdmin: _catatanController.text.trim(),
        riwayat: List.unmodifiable(_history),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riwayat ${widget.mitra.nama}',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _mitraNavy,
                ),
              ),
              const SizedBox(height: 8),
              ..._history.map((item) => _HistoryTile(item: item)),
              if (_history.isEmpty)
                Text(
                  'Belum ada riwayat mitra.',
                  style: GoogleFonts.manrope(fontSize: 12, color: _mitraMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreAction(String action) {
    if (action == 'copy') {
      Clipboard.setData(ClipboardData(text: widget.mitra.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID mitra disalin.')));
      return;
    }
    _showHistory();
  }

  @override
  Widget build(BuildContext context) {
    final mitra = widget.mitra;
    return Scaffold(
      backgroundColor: _mitraPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: _mitraNavy),
        ),
        title: Text(
          'Detail Mitra',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _mitraNavy,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru.')),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: _mitraMuted,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Aksi lainnya',
            onSelected: _showMoreAction,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'copy', child: Text('Salin ID Mitra')),
              PopupMenuItem(value: 'history', child: Text('Lihat Riwayat')),
            ],
            icon: const Icon(Icons.more_vert_rounded, color: _mitraMuted),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _mitraBlue,
              child: IconButton(
                tooltip: 'Admin LokaTrip',
                padding: EdgeInsets.zero,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Anda masuk sebagai Admin LokaTrip.'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            _MitraIdentityCard(mitra: mitra, status: _status),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ubah Status Mitra',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _mitraNavy,
                    ),
                  ),
                ),
                Text(
                  'Pilih satu status',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _mitraMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _StatusSelector(
              selected: _status,
              onSelected: (status) => setState(() => _status = status),
            ),
            const SizedBox(height: 8),
            _StatusDescription(status: _status),
            const SizedBox(height: 18),
            Text(
              'Pengaturan Tambahan',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _mitraNavy,
              ),
            ),
            const SizedBox(height: 8),
            _AdditionalSettings(
              ditampilkanDiBeranda: _ditampilkanDiBeranda,
              onVisibilityChanged: (value) =>
                  setState(() => _ditampilkanDiBeranda = value),
              controller: _catatanController,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Riwayat Terakhir',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _mitraNavy,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showHistory,
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _mitraBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: _cardDecoration(),
              child: Column(
                children: _history
                    .take(2)
                    .map((item) => _HistoryTile(item: item))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 19),
              label: Text(
                'Simpan Perubahan',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _mitraBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batalkan',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _mitraMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MitraIdentityCard extends StatelessWidget {
  final _MitraData mitra;
  final _MitraStatus status;

  const _MitraIdentityCard({required this.mitra, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _MitraPhoto(mitra: mitra, size: 56),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mitra.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _mitraNavy,
                  ),
                ),
                Text(
                  'PIC: ${mitra.status == _MitraStatus.pending ? 'Hendra Wijaya' : 'Admin Mitra'}',
                  style: GoogleFonts.manrope(fontSize: 10, color: _mitraMuted),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: _mitraMuted,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        mitra.lokasi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          color: _mitraMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          _StatusPill(
            label: switch (status) {
              _MitraStatus.active => 'Aktif Beroperasi',
              _MitraStatus.pending => 'Menunggu',
              _MitraStatus.rejected => 'Ditolak',
              _MitraStatus.suspended => 'Ditangguhkan',
            },
            textColor: switch (status) {
              _MitraStatus.active => const Color(0xFF065F46),
              _MitraStatus.pending => _mitraBlue,
              _MitraStatus.rejected ||
              _MitraStatus.suspended => const Color(0xFFB91C1C),
            },
            background: switch (status) {
              _MitraStatus.active => const Color(0xFFD8F4E9),
              _MitraStatus.pending => const Color(0xFFE5EDFF),
              _MitraStatus.rejected ||
              _MitraStatus.suspended => const Color(0xFFFFD8D5),
            },
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final _MitraStatus selected;
  final ValueChanged<_MitraStatus> onSelected;

  const _StatusSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const options = [
      (
        _MitraStatus.active,
        'Aktif',
        'Bisa menerima pesanan',
        Icons.check_circle_outline,
        _mitraBlue,
      ),
      (
        _MitraStatus.pending,
        'Menunggu',
        'Verifikasi / Ditinjau',
        Icons.hourglass_bottom_rounded,
        Color(0xFFF2B705),
      ),
      (
        _MitraStatus.suspended,
        'Ditangguhkan',
        'Operasional dibekukan',
        Icons.block_rounded,
        Color(0xFF64748B),
      ),
      (
        _MitraStatus.rejected,
        'Ditolak',
        'Pengajuan tidak disetujui',
        Icons.gavel_rounded,
        Color(0xFFDC2626),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 760;
        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: _cardDecoration(),
              child: GridView.count(
                crossAxisCount: desktop ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: desktop ? 1.9 : 2.15,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                children: options.map((option) {
                  final isSelected = selected == option.$1;
                  final selectedTextColor = option.$1 == _MitraStatus.pending
                      ? _mitraNavy
                      : Colors.white;
                  return InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () => onSelected(option.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? option.$5 : Colors.white,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option.$4,
                            size: 18,
                            color: isSelected ? selectedTextColor : _mitraMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.$2,
                            maxLines: 1,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? selectedTextColor
                                  : _mitraMuted,
                            ),
                          ),
                          Text(
                            option.$3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 8,
                              color: isSelected
                                  ? selectedTextColor.withValues(alpha: 0.9)
                                  : const Color(0xFF85899A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusDescription extends StatelessWidget {
  final _MitraStatus status;

  const _StatusDescription({required this.status});

  @override
  Widget build(BuildContext context) {
    final active = status == _MitraStatus.active;
    final text = switch (status) {
      _MitraStatus.active =>
        'Status Aktif memungkinkan paket wisata mitra tayang langsung dan dapat dipesan oleh wisatawan.',
      _MitraStatus.pending =>
        'Mitra menunggu proses verifikasi sebelum paket ditampilkan kepada wisatawan.',
      _MitraStatus.rejected =>
        'Pengajuan tidak disetujui. Mitra perlu melengkapi persyaratan sebelum diajukan kembali.',
      _MitraStatus.suspended =>
        'Operasional mitra dibekukan sementara dan paket tidak dapat dipesan.',
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(
            active ? Icons.info_outline_rounded : Icons.info_outline_rounded,
            size: 19,
            color: active ? const Color(0xFF047857) : _mitraBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 10,
                height: 1.4,
                color: _mitraMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdditionalSettings extends StatelessWidget {
  final bool ditampilkanDiBeranda;
  final ValueChanged<bool> onVisibilityChanged;
  final TextEditingController controller;

  const _AdditionalSettings({
    required this.ditampilkanDiBeranda,
    required this.onVisibilityChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tampilkan di Beranda Aplikasi',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _mitraNavy,
                      ),
                    ),
                    Text(
                      'Sematkan tanda mitra rekomendasi di halaman utama',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        height: 1.35,
                        color: _mitraMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: ditampilkanDiBeranda,
                onChanged: onVisibilityChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: _mitraBlue,
              ),
            ],
          ),
          const Divider(height: 18, color: _mitraBorder),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Catatan Admin (Opsional)',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _mitraNavy,
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: 1,
            maxLines: 3,
            maxLength: 250,
            style: GoogleFonts.manrope(fontSize: 11, color: _mitraNavy),
            decoration: InputDecoration(
              hintText: 'Contoh: Dokumen telah sesuai ketentuan',
              hintStyle: GoogleFonts.manrope(
                fontSize: 10,
                color: const Color(0xFF85899A),
              ),
              filled: true,
              fillColor: const Color(0xFFF0F4FF),
              counterStyle: GoogleFonts.manrope(fontSize: 9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MitraHistory {
  final String title;
  final String description;
  final String date;
  final IconData icon;

  const _MitraHistory({
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
  });
}

class _HistoryTile extends StatelessWidget {
  final _MitraHistory item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F1EC),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 16, color: const Color(0xFF047857)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _mitraNavy,
                  ),
                ),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 9, color: _mitraMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            item.date,
            style: GoogleFonts.manrope(fontSize: 9, color: _mitraMuted),
          ),
        ],
      ),
    );
  }
}
