import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin_mitra/pengajuan_mitra_screens.dart';
import 'package:lokatrip/features/login_screens.dart';
import 'package:lokatrip/features/splash_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('pihak wisata login opens the four-step application', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: LoginScreens()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Pihak Wisata'));
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(PengajuanMitraScreens), findsOneWidget);
    expect(find.text('Tahap 1: Info wisata'), findsOneWidget);
    final layoutError = tester.takeException();
    if (layoutError != null) debugPrint('$layoutError');
    expect(layoutError, isNull);

    await tester.enterText(find.byKey(const Key('destination')), 'Kawah Ijen');
    await tester.enterText(
      find.byKey(const Key('description')),
      'Wisata kawah',
    );
    await tester.enterText(find.byKey(const Key('location')), 'Banyuwangi');
    await tester.tap(find.text('Lanjut ke Tahap 2: Tiket & Kuota'));
    await tester.pumpAndSettle();
    expect(find.text('Tahap 2: Tiket dan kuota'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byKey(const Key('ticket')), 'Tiket Reguler');
    await tester.enterText(find.byKey(const Key('price')), '150000');
    await tester.enterText(find.byKey(const Key('quota')), '100');
    await tester.enterText(find.byKey(const Key('hours')), '01.00–12.00 WIB');
    await tester.tap(find.text('Lanjut ke Tahap 3: Legalitas'));
    await tester.pumpAndSettle();
    expect(find.text('Tahap 3: Legalitas'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byKey(const Key('nib')), '9120301923024');
    await tester.enterText(find.byKey(const Key('license')), 'TDUP-2026-01');
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Siapkan Pengajuan Tahap 4'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siapkan Pengajuan Tahap 4'));
    await tester.pumpAndSettle();
    expect(find.text('Tahap 3: Legalitas'), findsOneWidget);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Siapkan Pengajuan Tahap 4'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siapkan Pengajuan Tahap 4'));
    await tester.pumpAndSettle();

    expect(find.text('Tahap 4: Pelacakan pengajuan'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Kawah Ijen'), findsOneWidget);
    expect(find.textContaining('Belum terhubung ke server'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });

  testWidgets('application form renders on a desktop viewport', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: PengajuanMitraScreens()));
    await tester.pumpAndSettle();

    expect(find.text('Tahap 1: Info wisata'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });

  testWidgets('back button on first step returns to login and logs out', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'account_role': 'mitra',
    });

    await tester.pumpWidget(const MaterialApp(home: PengajuanMitraScreens()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kembali ke login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreens), findsOneWidget);
    expect(
      await SharedPreferences.getInstance().then(
        (prefs) => prefs.getBool('is_logged_in'),
      ),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mitra role survives splash and opens the saved application', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'account_role': 'mitra',
    });
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: SplashScreens()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(PengajuanMitraScreens), findsOneWidget);
    expect(find.text('Tahap 1: Info wisata'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.resetPhysicalSize();
  });
}
