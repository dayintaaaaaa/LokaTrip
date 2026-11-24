
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lokatrip/core/session_manager.dart';
import 'package:lokatrip/features/admin/dashboard_admin_screens.dart';
import 'package:lokatrip/features/admin/perizinan_admin_screens.dart';
import 'package:lokatrip/features/admin/verifikasi_mitra_admin_screens.dart';

void main() {
  final expirySoon = DateTime.now()
      .add(const Duration(days: 5))
      .toIso8601String()
      .split('T')
      .first;

  final documents = <Map<String, dynamic>>[
    {
      'id_dokumen': 128,
      'jenis_dokumen': 'NIB',
      'status_approve': 'N',
      'masa_berlaku_sampai': expirySoon,
      'admin_wisata': {
        'nama_lengkap_admin': 'Mitra Bromo',
        'username': 'mitrabromo',
      },
    },
    {
      'id_dokumen': 129,
      'jenis_dokumen': 'Izin Operasional',
      'status_approve': 'Y',
      'masa_berlaku_sampai': expirySoon,
      'admin_wisata': {
        'nama_lengkap_admin': 'Batu Adventure Park',
        'username': 'batuadventure',
      },
    },
  ];

  final wisata = <Map<String, dynamic>>[
    {
      'id_wisata': 128,
      'nama_wisata': 'Gunung Bromo Adventure',
      'deskripsi': 'Wisata petualangan Gunung Bromo.',
      'admin_wisata': {
        'nama_lengkap_admin': 'Mitra Bromo',
        'username': 'mitrabromo',
      },
      'kategori': {
        'nama_kategori': 'Wisata Alam',
      },
    },
  ];

  Future<void> prepareAdminSession() async {
    SharedPreferences.setMockInitialValues({});

    await SessionManager.setAdminSession(
      accessToken: 'test-admin-token',
    );
  }

  Widget buildDashboard() {
    return MaterialApp(
      home: DashboardAdminScreens(
        dashboardLoader: () async => {
          'wisata_aktif': 5,
          'wisata_menunggu_verifikasi': 1,
          'dokumen_menunggu_verifikasi': 1,
          'dokumen_aktif': 3,
          'mitra_aktif': 2,
        },
        wisataLoader: () async => wisata,
        documentsLoader: () async => documents,
      ),
    );
  }

  testWidgets('dashboard audit shortcut opens pending permit list', (
    tester,
  ) async {
    await prepareAdminSession();

    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(buildDashboard());
    await tester.pumpAndSettle();

    expect(find.text('Mulai'), findsOneWidget);

    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.byType(PerizinanAdminScreens), findsOneWidget);
    expect(find.text('Menunggu (1)'), findsOneWidget);
    expect(find.text('DOC-00128'), findsOneWidget);

    await tester.tap(find.text('DOC-00128'));
    await tester.pumpAndSettle();

    expect(find.byType(VerifikasiMitraAdminScreens), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
  });

  testWidgets('dashboard list and expiring permit actions open matching pages', (
    tester,
  ) async {
    await prepareAdminSession();

    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(buildDashboard());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();

    expect(find.byType(PerizinanAdminScreens), findsOneWidget);
    expect(find.text('Menunggu (1)'), findsOneWidget);
    expect(find.text('DOC-00128'), findsOneWidget);

    Navigator.of(
      tester.element(find.byType(PerizinanAdminScreens)),
    ).pop();

    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Prioritas Regulasi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prioritas Regulasi'));
    await tester.pumpAndSettle();

    expect(find.byType(PerizinanAdminScreens), findsOneWidget);
    expect(find.text('Akan berakhir (1)'), findsOneWidget);
    expect(find.text('DOC-00129'), findsOneWidget);

    await tester.tap(find.text('DOC-00129'));
    await tester.pumpAndSettle();

    expect(find.byType(VerifikasiMitraAdminScreens), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
  });

  testWidgets('dashboard wisata verification action opens matching page', (
    tester,
  ) async {
    await prepareAdminSession();

    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(buildDashboard());
    await tester.pumpAndSettle();

    expect(find.text('Gunung Bromo Adventure'), findsOneWidget);

    await tester.ensureVisible(find.text('Periksa').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Periksa').first);
    await tester.pumpAndSettle();

    expect(find.byType(VerifikasiMitraAdminScreens), findsOneWidget);
    expect(find.text('Gunung Bromo Adventure'), findsNWidgets(2));
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
  });
}
