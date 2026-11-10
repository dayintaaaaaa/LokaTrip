import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin/laporan_admin_screens.dart';
import 'package:lokatrip/widgets/admin_bottom_navigator.dart';

void main() {
  testWidgets('report page renders desktop analytics and changes period', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: LaporanAdminScreens()));
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan platform'), findsOneWidget);
    expect(find.text('Pertumbuhan mitra'), findsOneWidget);
    expect(find.text('Status legalitas & izin'), findsOneWidget);
    expect(
      find.text(
        'Data contoh untuk rancangan laporan; belum terhubung ke backend.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Tahun'));
    await tester.pumpAndSettle();
    expect(find.text('Januari–September 2026'), findsWidgets);

    tester.view.physicalSize = const Size(900, 1000);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AdminBottomNavigator), findsOneWidget);

    tester.view.resetPhysicalSize();
  });
}
