import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin/laporan_admin_screens.dart';
import 'package:lokatrip/widgets/admin_bottom_navigator.dart';

void main() {
  testWidgets('report page handles an unavailable Supabase session', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: LaporanAdminScreens()));
    await tester.pumpAndSettle();

    expect(find.text('Laporan'), findsWidgets);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Tahun'));
    await tester.pumpAndSettle();
    expect(find.text('Coba lagi'), findsOneWidget);

    tester.view.physicalSize = const Size(900, 1000);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AdminBottomNavigator), findsOneWidget);

    tester.view.resetPhysicalSize();
  });
}
