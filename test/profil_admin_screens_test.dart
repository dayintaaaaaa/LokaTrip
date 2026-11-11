import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokatrip/features/admin/preferensi_kontrol_admin_screens.dart';
import 'package:lokatrip/features/admin/profil_screens.dart';

void main() {
  testWidgets('profile preference entries open complete pages', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(const MaterialApp(home: ProfilAdminScreens()));
    await tester.pumpAndSettle();

    final pages = <({String menu, String title, PreferensiAdminSection page})>[
      (
        menu: 'Notifikasi',
        title: 'Atur pemberitahuan admin',
        page: PreferensiAdminSection.notifications,
      ),
      (
        menu: 'Keamanan',
        title: 'Keamanan akun administrator',
        page: PreferensiAdminSection.security,
      ),
      (
        menu: 'Bantuan & SOP Regulasi',
        title: 'Panduan operasional',
        page: PreferensiAdminSection.help,
      ),
      (
        menu: 'Tentang LokaTrip',
        title: 'LokaTrip Admin',
        page: PreferensiAdminSection.about,
      ),
    ];

    for (final page in pages) {
      await tester.ensureVisible(find.text(page.menu));
      await tester.tap(find.text(page.menu));
      await tester.pumpAndSettle();

      expect(find.byType(PreferensiKontrolAdminScreens), findsOneWidget);
      expect(find.text(page.title), findsOneWidget);
      expect(find.textContaining('belum tersinkron'), findsOneWidget);
      expect(tester.takeException(), isNull);

      if (page.page == PreferensiAdminSection.notifications) {
        expect(find.byType(SwitchListTile), findsNWidgets(4));
        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      if (page.page == PreferensiAdminSection.security) {
        expect(find.text('Autentikasi dua faktor'), findsOneWidget);
        expect(find.text('Belum tersedia'), findsNWidgets(2));
      }

      if (page.page == PreferensiAdminSection.help) {
        await tester.tap(find.text('Memeriksa pengajuan mitra'));
        await tester.pumpAndSettle();
        expect(find.textContaining('cocokkan data pengajuan'), findsOneWidget);
      }

      await tester.tap(find.byTooltip('Kembali ke profil'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilAdminScreens), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    tester.view.resetPhysicalSize();
  });
}
