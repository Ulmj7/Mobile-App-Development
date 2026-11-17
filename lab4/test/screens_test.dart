import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/screens/detail_screen.dart';
import 'package:travel_mn/screens/map_picker_screen.dart';
import 'package:travel_mn/state/favorites.dart';

import 'helpers.dart';

void main() {
  group('explore map', () {
    testWidgets('shows a marker per located place and attribution', (
      tester,
    ) async {
      await openApp(tester, height: 1000);
      await goToTab(tester, 'Газрын зураг');
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
      expect(find.byIcon(Icons.location_pin), findsWidgets);
    });

    testWidgets('tapping a marker opens that place\'s detail, back returns', (
      tester,
    ) async {
      await openApp(tester, height: 1000);
      await goToTab(tester, 'Газрын зураг');
      // Khuvsgul is far from the other markers; central ones overlap at the
      // initial country-wide zoom.
      final marker = find.byTooltip('Хөвсгөл нуур');
      expect(marker, findsOneWidget);
      await tester.tap(marker);
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('900 км'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets(
      'zooming in separates Terelj from Khustai so Terelj can be opened',
      (tester) async {
        await openApp(tester, height: 900);
        await goToTab(tester, 'Газрын зураг');
        final terelj = find.byTooltip('Горхи-Тэрэлж');
        final khustai = find.byTooltip('Хустайн нуруу');
        expect(tester.getSize(terelj), const Size(36, 36));
        // At country zoom the two pins overlap...
        expect(
          tester.getRect(terelj).overlaps(tester.getRect(khustai)),
          isTrue,
        );

        // ...one zoom step and a pan later they are apart.
        await tester.tap(find.byTooltip('Томруулах'));
        await tester.pumpAndSettle();
        await tester.dragFrom(const Offset(200, 250), const Offset(-200, 0));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(terelj).overlaps(tester.getRect(khustai)),
          isFalse,
        );

        await tester.tap(terelj);
        await tester.pumpAndSettle();
        expect(find.byType(DetailScreen), findsOneWidget);
        expect(
          tester.widget<DetailScreen>(find.byType(DetailScreen)).place.id,
          'terelj',
        );
      },
    );

    testWidgets('zoom out stops at the minimum zoom without errors', (
      tester,
    ) async {
      await openApp(tester, height: 900);
      await goToTab(tester, 'Газрын зураг');
      for (var i = 0; i < 8; i++) {
        await tester.tap(find.byTooltip('Жижигрүүлэх'));
        await tester.pump();
      }
      for (var i = 0; i < 20; i++) {
        await tester.tap(find.byTooltip('Томруулах'));
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Томруулах'), findsOneWidget);
    });
  });

  group('detail', () {
    testWidgets('a place with a location opens a read-only map', (
      tester,
    ) async {
      await openApp(tester, height: 1200);
      await tester.tap(find.text('Горхи-Тэрэлж'));
      await tester.pumpAndSettle();
      expect(find.text('47.88843, 107.42282'), findsOneWidget);
      await tester.tap(find.text('Байршил'));
      await tester.pumpAndSettle();
      expect(find.byType(MapPickerScreen), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
    });

    testWidgets('a place without a location has no map link', (tester) async {
      await openApp(tester, height: 3000, extraPlaces: [userPlace()]);
      await tester.tap(find.text('Тест нуур'));
      await tester.pumpAndSettle();
      expect(find.text('Байршил'), findsNothing);
    });

    testWidgets('a single photograph has no gallery controls', (tester) async {
      await openApp(tester);
      await tester.tap(find.text('Горхи-Тэрэлж'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('photo-gallery')), findsNothing);
      expect(find.textContaining(' / '), findsNothing);
    });

    testWidgets('the favourite button toggles', (tester) async {
      await openApp(tester);
      await tester.tap(find.text('Горхи-Тэрэлж'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Дуртайд нэмэх'));
      await tester.pumpAndSettle();
      expect(isFavorite('terelj'), isTrue);
      await tester.tap(find.byTooltip('Дуртайгаас хасах'));
      await tester.pumpAndSettle();
      expect(isFavorite('terelj'), isFalse);
    });
  });

  // The smallest phone (portrait) and a phone on its side, largest text.
  for (final (w, h) in [(320.0, 568.0), (640.0, 320.0)]) {
    group('text ×1.8 on a ${w.toInt()}×${h.toInt()} screen', () {
      Future<void> open(WidgetTester tester) =>
          openApp(tester, width: w, height: h, textScale: 1.8);

      void noErrors(WidgetTester tester) =>
          expect(tester.takeException(), isNull);

      testWidgets('empty favourites does not overflow and scrolls', (
        tester,
      ) async {
        await open(tester);
        await goToTab(tester, 'Дуртай');
        expect(find.text('Дуртай газар алга'), findsOneWidget);
        noErrors(tester);
        // Everything stays reachable.
        await tester.scrollUntilVisible(
          find.textContaining('зүрхэн тэмдэг'),
          50,
          scrollable: find.byType(Scrollable).first,
        );
        noErrors(tester);
      });

      testWidgets('login, places and settings do not overflow', (tester) async {
        await open(tester);
        noErrors(tester);
        await goToTab(tester, 'Тохиргоо');
        noErrors(tester);
      });

      testWidgets('map picker with the keyboard open does not overflow', (
        tester,
      ) async {
        installFakeImagePicker();
        await open(tester);
        await tester.tap(find.byTooltip('Газар нэмэх'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Газрын зураг дээр байршил тэмдэглэх'),
        );
        await tester.tap(find.text('Газрын зураг дээр байршил тэмдэглэх'));
        await tester.pumpAndSettle();
        expect(find.byType(MapPickerScreen), findsOneWidget);

        // The soft keyboard takes 300 px.
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        noErrors(tester);
        await tester.enterText(find.byType(TextField), 'Хөвсгөл');
        await tester.pumpAndSettle();
        noErrors(tester);
      });
    });
  }

  // Dark theme and the largest text scale on a phone and a tablet: every
  // screen must lay out without overflow or exceptions.
  for (final width in [360.0, 800.0]) {
    group('dark theme, text ×1.8, ${width.toInt()} dp', () {
      Future<void> open(
        WidgetTester tester, {
        bool loggedIn = true,
        double height = 900,
      }) => openApp(
        tester,
        width: width,
        height: height,
        textScale: 1.8,
        brightness: Brightness.dark,
        loggedIn: loggedIn,
        extraPlaces: [userPlace(images: 3)],
      );

      void noErrors(WidgetTester tester) =>
          expect(tester.takeException(), isNull);

      testWidgets('login', (tester) async {
        await open(tester, loggedIn: false);
        expect(
          Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
          Brightness.dark,
        );
        noErrors(tester);
      });

      testWidgets('places, filter sheet and search', (tester) async {
        await open(tester);
        noErrors(tester);
        await tester.tap(find.byTooltip('Шүүлтүүр'));
        await tester.pumpAndSettle();
        noErrors(tester);
        await tester.tap(find.widgetWithText(FilledButton, 'Болсон'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Хайх'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Тэрэлж');
        await tester.pumpAndSettle();
        noErrors(tester);
      });

      testWidgets('detail with a photo gallery', (tester) async {
        await open(tester, height: 4000);
        await tester.tap(find.text('Тест нуур'));
        await tester.pumpAndSettle();
        expect(find.byType(DetailScreen), findsOneWidget);
        noErrors(tester);
      });

      testWidgets('favourites, explore and settings', (tester) async {
        await open(tester);
        setFavorite('terelj', true);
        await goToTab(tester, 'Дуртай');
        noErrors(tester);
        await goToTab(tester, 'Газрын зураг');
        noErrors(tester);
        await goToTab(tester, 'Тохиргоо');
        noErrors(tester);
      });

      testWidgets('change password and add place forms', (tester) async {
        installFakeImagePicker();
        await open(tester);
        await goToTab(tester, 'Тохиргоо');
        await tester.tap(find.text('Нууц үг солих').first);
        await tester.pumpAndSettle();
        noErrors(tester);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await goToTab(tester, 'Газрууд');
        await tester.tap(find.byTooltip('Газар нэмэх'));
        await tester.pumpAndSettle();
        noErrors(tester);
      });

      testWidgets('map picker', (tester) async {
        installFakeImagePicker();
        await open(tester);
        await tester.tap(find.byTooltip('Газар нэмэх'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Газрын зураг дээр байршил тэмдэглэх'),
        );
        await tester.tap(find.text('Газрын зураг дээр байршил тэмдэглэх'));
        await tester.pumpAndSettle();
        expect(find.byType(MapPickerScreen), findsOneWidget);
        noErrors(tester);
      });
    });
  }
}
