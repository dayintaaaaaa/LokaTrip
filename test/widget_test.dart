
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lokatrip/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app opens with the current login screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    tester.view.physicalSize = const Size(1024, 900);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Memastikan halaman login tampil.
    expect(find.text('Login'), findsOneWidget);
    expect(
      find.text('Email, username, atau nomor telepon'),
      findsOneWidget,
    );
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    // Memastikan pilihan jenis akun lama tidak muncul.
    expect(find.text('Jenis akun'), findsNothing);

    // Menguji validasi ketika login tanpa mengisi data.
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Email/username/nomor telepon dan password wajib diisi.',
      ),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
  });
}
