import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin/perizinan_admin_screens.dart';
import 'package:lokatrip/widgets/admin_bottom_navigator.dart';

void main() {
  testWidgets('license page filters records and verifies a pending permit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: PerizinanAdminScreens()));
    await tester.pumpAndSettle();

    expect(find.text('Audit & verifikasi izin'), findsOneWidget);
    expect(find.text('Gunung Bromo Adventure'), findsOneWidget);
    expect(find.text('Status legalitas & izin'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Kirim pengingat'));
    await tester.pumpAndSettle();
    expect(
      find.text('Pengingat perpanjangan untuk CV Alam Raya disiapkan.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Kedaluwarsa (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Waterpark Tirta Safari'), findsOneWidget);
    expect(find.text('Gunung Bromo Adventure'), findsNothing);

    await tester.tap(find.text('Semua (5)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('IZ-2026-00128'));
    await tester.pumpAndSettle();
    expect(find.text('Data mitra'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.text('1. Data'), findsOneWidget);
    await tester.tap(find.text('Lanjut ke Dokumen (Tahap 2)'));
    await tester.pumpAndSettle();
    expect(find.text('Dokumen legalitas'), findsOneWidget);
    await tester.tap(find.text('Tolak pengajuan'));
    await tester.pumpAndSettle();
    expect(find.text('DITOLAK'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali ke Perizinan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ditolak (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('IZ-2026-00128'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('2. Dokumen'), findsOneWidget);

    tester.view.physicalSize = const Size(900, 1000);
    await tester.tap(find.byTooltip('Kembali ke Perizinan'));
    await tester.pumpAndSettle();
    expect(find.byType(AdminBottomNavigator), findsOneWidget);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });

  testWidgets('active partner opens with all four audit stages complete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: PerizinanAdminScreens()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PT Bajo Bahari Adventure'));
    await tester.pumpAndSettle();

    expect(find.text('IZIN AKTIF'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNWidgets(4));
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });

  testWidgets('approval updates the permit card to active', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: PerizinanAdminScreens()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('IZ-2026-00128'));
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
    await tester.tap(find.text('Selesai — semua tahap terverifikasi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aktif (2)'));
    await tester.pumpAndSettle();
    expect(find.text('IZ-2026-00128'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });
}
