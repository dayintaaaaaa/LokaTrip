import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin_mitra/pengajuan_mitra_screens.dart';
import 'package:lokatrip/features/admin_mitra/wisata_saya_mitra_screen.dart';
import 'package:lokatrip/features/splash_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lokatrip/features/login_screens.dart';

void main() {
  testWidgets('application form completes the four-step flow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: PengajuanMitraScreens()));
    await tester.pumpAndSettle();

    expect(find.byType(PengajuanMitraScreens), findsOneWidget);
    expect(find.text('Tahap 1: Info wisata'), findsOneWidget);
    expect(tester.takeException(), isNull);

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

    expect(find.text('Tahap 3: Dokumen perizinan'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const Key('legal-declaration')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Siapkan Pengajuan Tahap 4'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Siapkan Pengajuan Tahap 4'));
    await tester.pumpAndSettle();

    expect(find.text('Tahap 3: Dokumen perizinan'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('legal-declaration')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('legal-declaration')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Siapkan Pengajuan Tahap 4'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Siapkan Pengajuan Tahap 4'));
    await tester.pumpAndSettle();

    expect(find.text('Tahap 4: Pelacakan pengajuan'), findsOneWidget);
    expect(find.text('Kawah Ijen'), findsOneWidget);
    expect(find.text('Status: Siap dikirim ke admin'), findsOneWidget);

    expect(find.text('Alur verifikasi LokaTrip'), findsOneWidget);
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

  testWidgets('back button on first step opens Wisata Saya', (tester) async {
    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'account_role': 'mitra',
    });

    await tester.pumpWidget(const MaterialApp(home: PengajuanMitraScreens()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ke Wisata Saya'));
    await tester.pumpAndSettle();

    expect(find.byType(WisataSayaMitraScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mitra without token is redirected to login', (tester) async {
    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'account_role': 'mitra',
    });

    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: SplashScreens()));

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreens), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
  });
}
