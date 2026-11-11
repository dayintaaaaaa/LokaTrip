import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin/dashboard_admin_screens.dart';
import 'package:lokatrip/features/admin/perizinan_admin_screens.dart';
import 'package:lokatrip/features/admin/verifikasi_mitra_admin_screens.dart';

void main() {
  testWidgets('dashboard audit shortcuts open the verification page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: DashboardAdminScreens()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();
    expect(find.byType(VerifikasiMitraAdminScreens), findsOneWidget);
    expect(find.text('IZ-2026-00128'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Kembali ke Perizinan'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Periksa').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Periksa').first);
    await tester.pumpAndSettle();

    expect(find.byType(VerifikasiMitraAdminScreens), findsOneWidget);
    expect(find.text('Gunung Bromo Adventure'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });

  testWidgets('dashboard list and license review actions open matching pages', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: DashboardAdminScreens()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();
    expect(find.byType(PerizinanAdminScreens), findsOneWidget);
    expect(find.text('Menunggu (2)'), findsOneWidget);
    expect(find.text('Gunung Bromo Adventure'), findsOneWidget);

    Navigator.of(tester.element(find.byType(PerizinanAdminScreens))).pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lihat Semua'));
    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();
    expect(find.text('Akan berakhir (1)'), findsOneWidget);
    expect(find.text('Batu Adventure Park'), findsOneWidget);
    expect(find.text('Gunung Bromo Adventure'), findsNothing);

    Navigator.of(tester.element(find.byType(PerizinanAdminScreens))).pop();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Tinjau Izin').first);
    await tester.tap(find.text('Tinjau Izin').first);
    await tester.pumpAndSettle();
    expect(find.byType(VerifikasiMitraAdminScreens), findsOneWidget);
    expect(find.text('IZ-2026-00128'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });
}
