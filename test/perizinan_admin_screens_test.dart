import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin/perizinan_admin_screens.dart';
import 'package:lokatrip/widgets/admin_bottom_navigator.dart';

List<Map<String, dynamic>> _fixtureRows() {
  final today = DateTime.now();

  String dateFromNow(int days) {
    final date = today.add(Duration(days: days));
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> document({
    required int id,
    required String partner,
    required String username,
    required String status,
    required String expiry,
    required String note,
  }) {
    return {
      'id_dokumen': id,
      'jenis_dokumen': 'Ekraf & Wisata',
      'status_approve': status,
      'masa_berlaku_sampai': expiry,
      'catatan_admin': note,
      'admin_wisata': {'nama_lengkap_admin': partner, 'username': username},
    };
  }

  return [
    document(
      id: 128,
      partner: 'CV Pesona Nusantara',
      username: 'pesona',
      status: 'N',
      expiry: dateFromNow(300),
      note: 'Menunggu audit lapangan.',
    ),
    document(
      id: 114,
      partner: 'CV Alam Raya',
      username: 'alamraya',
      status: 'Y',
      expiry: dateFromNow(15),
      note: 'Polis asuransi perlu diperpanjang.',
    ),
    document(
      id: 129,
      partner: 'PT Jelajah Indonesia',
      username: 'jelajah',
      status: 'N',
      expiry: dateFromNow(300),
      note: 'Menunggu pemeriksaan dokumen.',
    ),
    document(
      id: 42,
      partner: 'CV Tirta Lestari',
      username: 'tirta',
      status: 'Y',
      expiry: dateFromNow(-90),
      note: 'Izin melewati masa berlaku.',
    ),
    document(
      id: 76,
      partner: 'PT Bajo Bahari Adventure',
      username: 'bajo',
      status: 'Y',
      expiry: dateFromNow(300),
      note: 'Dokumen terverifikasi.',
    ),
  ];
}

Future<void> _ignoreDecision({
  required int id,
  required String decision,
  required String note,
}) async {}

Future<void> _pumpPerizinan(
  WidgetTester tester, {
  String initialFilter = 'Semua',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PerizinanAdminScreens(
        initialFilter: initialFilter,
        documentsLoader: () async => _fixtureRows(),
        documentDecisionHandler: _ignoreDecision,
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('license page filters records and verifies a pending permit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;

    await _pumpPerizinan(tester);

    expect(find.text('Audit & verifikasi izin'), findsOneWidget);
    expect(find.text('CV Pesona Nusantara'), findsOneWidget);
    expect(find.text('Status legalitas & izin'), findsNothing);
    expect(tester.takeException(), isNull);

    // Menguji pengingat izin yang akan berakhir.
    await tester.tap(find.text('Kirim pengingat'));
    await tester.pumpAndSettle();

    expect(
      find.text('Pengingat perpanjangan untuk CV Alam Raya disiapkan.'),
      findsOneWidget,
    );

    // Menguji filter kedaluwarsa.
    await tester.tap(find.text('Kedaluwarsa (1)'));
    await tester.pumpAndSettle();

    expect(find.text('DOC-00042'), findsOneWidget);
    expect(find.text('CV Tirta Lestari'), findsOneWidget);
    expect(find.text('DOC-00128'), findsNothing);

    // Kembali ke semua data.
    await tester.tap(find.text('Semua (5)'));
    await tester.pumpAndSettle();

    // Membuka dokumen yang menunggu audit.
    await tester.tap(find.text('DOC-00128'));
    await tester.pumpAndSettle();

    expect(find.text('Data mitra'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.text('1. Data'), findsOneWidget);

    // Melanjutkan ke tahap dokumen.
    await tester.tap(find.text('Lanjut ke Dokumen (Tahap 2)'));
    await tester.pumpAndSettle();

    expect(find.text('Dokumen legalitas'), findsOneWidget);

    // Menolak pengajuan pada tahap dokumen.
    await tester.tap(find.text('Tolak pengajuan'));
    await tester.pumpAndSettle();

    expect(find.text('DITOLAK'), findsOneWidget);

    // Kembali ke daftar.
    await tester.tap(find.byTooltip('Kembali ke Perizinan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ditolak (1)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('DOC-00128'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('2. Dokumen'), findsOneWidget);

    // Memeriksa tampilan navigasi pada ukuran berbeda.
    await tester.tap(find.byTooltip('Kembali ke Perizinan'));
    await tester.pumpAndSettle();

    tester.view.physicalSize = const Size(900, 1000);
    await tester.pumpAndSettle();

    expect(find.byType(AdminBottomNavigator), findsOneWidget);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('active partner opens with all four audit stages complete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;

    await _pumpPerizinan(tester);

    await tester.tap(find.text('PT Bajo Bahari Adventure'));
    await tester.pumpAndSettle();

    expect(find.text('IZIN AKTIF'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(4));
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('approval updates the permit card to active', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;

    await _pumpPerizinan(tester);

    await tester.tap(find.text('DOC-00128'));
    await tester.pumpAndSettle();

    for (final next in [
      'Lanjut ke Dokumen (Tahap 2)',
      'Lanjut ke Wisata (Tahap 3)',
      'Lanjut ke Keputusan (Tahap 4)',
    ]) {
      await tester.tap(find.text(next));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Terbitkan izin & aktifkan mitra'));
    await tester.pumpAndSettle();

    expect(find.text('IZIN AKTIF'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(4));

    await tester.tap(find.textContaining('semua tahap terverifikasi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aktif (2)'));
    await tester.pumpAndSettle();

    expect(find.text('DOC-00128'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
