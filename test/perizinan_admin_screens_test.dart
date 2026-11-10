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
    expect(find.text('Tandai diverifikasi'), findsOneWidget);
    await tester.tap(find.text('Tandai diverifikasi'));
    await tester.pumpAndSettle();
    expect(
      find.text('IZ-2026-00128 ditandai siap setelah audit.'),
      findsOneWidget,
    );

    tester.view.physicalSize = const Size(900, 1000);
    await tester.pumpAndSettle();
    expect(find.byType(AdminBottomNavigator), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
  });
}
