import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/main.dart';
import 'package:travel_mn/screens/detail_screen.dart';
import 'package:travel_mn/widgets/place_card.dart';

Future<void> openApp(
  WidgetTester tester, {
  double width = 390,
  double height = 844,
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(const TravelApp());
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 390.0, 599.0, 600.0, 839.0, 840.0, 1280.0]) {
    testWidgets('responsive layout at ${width.toInt()} dp', (tester) async {
      await openApp(tester, width: width);
      if (width < 840) {
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, width < 600 ? 2 : 3);
        expect(find.byType(PlaceDetailView), findsNothing);
      } else {
        expect(find.byType(GridView), findsNothing);
        expect(find.byType(PlaceDetailView), findsOneWidget);
        expect(find.text('Горхи-Тэрэлж'), findsNWidgets(2));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('card opens detail and system back returns to grid', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.byType(PlaceCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.text('70 км'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(DetailScreen), findsNothing);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('wide selection updates the detail without pushing a route', (
    tester,
  ) async {
    await openApp(tester, width: 1280);
    await tester.tap(find.text('Хөвсгөл нуур'));
    await tester.pumpAndSettle();
    final detail = tester.widget<PlaceDetailView>(find.byType(PlaceDetailView));
    expect(detail.place.id, 'khuvsgul');
    expect(find.text('900 км'), findsOneWidget);
    expect(find.byType(DetailScreen), findsNothing);
  });

  testWidgets('search finds a destination and opens it', (tester) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('Хайх'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Хөвсгөл');
    await tester.pumpAndSettle();
    expect(find.text('Хонгорын элс'), findsNothing);
    await tester.tap(find.text('Хөвсгөл нуур'));
    await tester.pumpAndSettle();
    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.text('900 км'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search reports no results and clearing restores the list', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.byTooltip('Хайх'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'no-such-place');
    await tester.pumpAndSettle();
    expect(find.textContaining('Газар олдсонгүй'), findsOneWidget);
    await tester.tap(find.byTooltip('Арилгах'));
    await tester.pumpAndSettle();
    expect(find.text('Горхи-Тэрэлж'), findsOneWidget);
  });

  testWidgets('favorites can be added, filtered, and removed', (tester) async {
    await openApp(tester);
    await tester.tap(find.byType(PlaceCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Дуртайд нэмэх'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Дуртайгаас хасах'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дуртай'));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceCard), findsOneWidget);

    await tester.tap(find.byType(PlaceCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Дуртайгаас хасах'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Дуртай газар алга'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add location opens a working saved-place selector', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CheckboxListTile>(find.byType(CheckboxListTile).first)
          .value,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 700.0, 840.0, 1280.0]) {
    testWidgets('dark theme and large text at ${width.toInt()} dp', (
      tester,
    ) async {
      await openApp(
        tester,
        width: width,
        textScale: 1.8,
        brightness: Brightness.dark,
      );
      final material = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(material.themeMode, ThemeMode.system);
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
