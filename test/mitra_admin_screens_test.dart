import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin/mitra_admin_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('mitra card opens detail and saves status and settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: MitraAdminScreens()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CV Pesona Nusantara').first);
    await tester.pumpAndSettle();

    expect(find.text('Detail Mitra'), findsOneWidget);
    await tester.ensureVisible(find.text('Ditangguhkan').first);
    await tester.tap(find.text('Ditangguhkan').first);
    await tester.pumpAndSettle();

    final noteField = find.byType(TextField).last;
    await tester.ensureVisible(noteField);
    await tester.enterText(noteField, 'Dokumen sudah ditinjau admin');
    await tester.ensureVisible(find.text('Simpan Perubahan'));
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ditangguhkan').first);
    await tester.pumpAndSettle();
    expect(find.text('CV Pesona Nusantara'), findsOneWidget);

    await tester.tap(find.text('CV Pesona Nusantara').first);
    await tester.pumpAndSettle();
    expect(find.text('Dokumen sudah ditinjau admin'), findsOneWidget);
    expect(find.text('Status Ditangguhkan'), findsOneWidget);

    await tester.tap(find.text('Lihat Semua'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat CV Pesona Nusantara'), findsOneWidget);

    tester.view.resetPhysicalSize();
  });
}
