// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lokatrip/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app opens with admin selected in the login flow', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1024, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Jenis akun'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Pihak Wisata'), findsOneWidget);
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Pengajuan Menunggu Verifikasi'), findsOneWidget);
    expect(
      await SharedPreferences.getInstance().then(
        (prefs) => prefs.getString('account_role'),
      ),
      'admin',
    );
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });
}
