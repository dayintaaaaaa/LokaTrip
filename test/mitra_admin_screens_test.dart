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

    await tester.pumpWidget(
      const MaterialApp(home: MitraAdminScreens(useSampleDataForTesting: true)),
    );
    await tester.pumpAndSettle();

    // Buka detail mitra
    await tester.tap(find.text('CV Pesona Nusantara').first);
    await tester.pumpAndSettle();

    expect(find.text('Detail Mitra'), findsOneWidget);

    // Pilih status ditangguhkan
    final status = find.text('Ditangguhkan').first;
    await tester.ensureVisible(status);
    await tester.tap(status);
    await tester.pumpAndSettle();

    // Isi catatan admin
    final noteField = find.byType(TextField).last;
    await tester.ensureVisible(noteField);
    await tester.enterText(noteField, 'Dokumen sudah ditinjau admin');

    // Simpan perubahan
    final simpan = find.text('Simpan Perubahan');
    await tester.ensureVisible(simpan);
    await tester.tap(simpan);
    await tester.pumpAndSettle();

    // Cari ListView tab berdasarkan tab Aktif
    final tabsList = find
        .ancestor(
          of: find.text('Aktif').first,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is ListView && widget.scrollDirection == Axis.horizontal,
          ),
        )
        .first;

    // Geser tab ke kiri agar Ditangguhkan terlihat
    await tester.drag(tabsList, const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Pilih tab Ditangguhkan
    final tabDitangguhkan = find.text('Ditangguhkan').first;
    expect(tabDitangguhkan, findsOneWidget);

    await tester.tap(tabDitangguhkan);
    await tester.pumpAndSettle();

    // Pastikan mitra muncul
    expect(find.text('CV Pesona Nusantara'), findsOneWidget);

    // Buka detail kembali
    await tester.tap(find.text('CV Pesona Nusantara').first);
    await tester.pumpAndSettle();

    expect(find.text('Detail Mitra'), findsOneWidget);

    // Pastikan catatan dan status tersimpan
    expect(find.text('Dokumen sudah ditinjau admin'), findsOneWidget);
    expect(find.text('Ditangguhkan'), findsWidgets);
    // Buka seluruh riwayat melalui menu aksi
    await tester.tap(find.byTooltip('Aksi lainnya'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lihat Riwayat'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat CV Pesona Nusantara'), findsOneWidget);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
