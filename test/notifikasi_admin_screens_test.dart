import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin/notifikasi_admin_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('notification page adapts to desktop widths and filters items', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: NotifikasiAdminScreens()));
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    expect(find.text('Notifikasi desktop'), findsOneWidget);
    expect(find.text('2 Baru'), findsOneWidget);
    expect(find.byTooltip('Kembali'), findsOneWidget);

    await tester.tap(find.text('Perizinan 1'));
    await tester.pumpAndSettle();
    expect(find.text('Izin Akan Berakhir'), findsOneWidget);
    expect(find.text('Pengajuan Mitra Baru'), findsNothing);

    tester.view.physicalSize = const Size(860, 900);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Notifikasi'), findsOneWidget);

    tester.view.resetPhysicalSize();
  });
}
