import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/screens/detail_screen.dart';
import 'package:travel_mn/state/favorites.dart';
import 'package:travel_mn/widgets/place_card.dart';

import 'helpers.dart';

Future<void> openFilter(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Шүүлтүүр'));
  await tester.pumpAndSettle();
}

Future<void> closeFilter(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Болсон'));
  await tester.pumpAndSettle();
}

Future<void> rate(WidgetTester tester, int stars) async {
  final input = find.byTooltip('$stars од');
  await tester.ensureVisible(input);
  await tester.tap(input);
  await tester.pumpAndSettle();
}

void main() {
  group('navigation', () {
    testWidgets('bottom bar below 600 dp, rail from 600 dp', (tester) async {
      await openApp(tester, width: 599);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('a 600 dp wide window uses the rail', (tester) async {
      await openApp(tester, width: 600);
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('all four destinations open their page', (tester) async {
      await openApp(tester);
      expect(find.text('Аяллын газрууд'), findsOneWidget);
      await goToTab(tester, 'Дуртай');
      expect(find.text('Дуртай газрууд'), findsOneWidget);
      await goToTab(tester, 'Газрын зураг');
      expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
      await goToTab(tester, 'Тохиргоо');
      expect(find.text('Нууц үг солих'), findsOneWidget);
      await goToTab(tester, 'Газрууд');
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('the bar is hidden on detail pages, back returns to the grid', (
      tester,
    ) async {
      await openApp(tester);
      await tester.tap(find.byType(PlaceCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  group('grid', () {
    // The grid sizes itself from the space next to the rail, not the window.
    for (final width in [320.0, 599.0, 700.0, 1000.0, 1400.0, 1800.0]) {
      testWidgets(
        'column count follows the grid width at ${width.toInt()} dp',
        (tester) async {
          await openApp(tester, width: width);
          final delegate =
              tester.widget<GridView>(find.byType(GridView)).gridDelegate
                  as SliverGridDelegateWithFixedCrossAxisCount;
          final gridWidth = tester.getSize(find.byType(GridView)).width;
          expect(
            delegate.crossAxisCount,
            gridWidth < 600
                ? 2
                : gridWidth < 900
                ? 3
                : gridWidth < 1200
                ? 4
                : 5,
          );
          if (width < 600) expect(delegate.crossAxisCount, 2);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('lists the ten bundled places in catalogue order', (
      tester,
    ) async {
      await openApp(tester, height: 3000);
      expect(cardIds(tester), hasLength(10));
      expect(cardIds(tester).first, 'terelj');
      expect(find.text('Горхи-Тэрэлж'), findsOneWidget);
    });

    testWidgets('card shows the rating and opens the detail page', (
      tester,
    ) async {
      await openApp(tester);
      await tester.tap(find.byType(PlaceCard).first);
      await tester.pumpAndSettle();
      expect(find.text('70 км'), findsOneWidget);
      expect(find.text('(128 үнэлгээ)'), findsOneWidget);
    });
  });

  group('favorites', () {
    testWidgets('add from detail, list, remove, undo', (tester) async {
      await openApp(tester);
      await tester.tap(find.byType(PlaceCard).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Дуртайд нэмэх'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Дуртайгаас хасах'), findsOneWidget);
      expect(favoriteIds.value, {'terelj'});
      await tester.pageBack();
      await tester.pumpAndSettle();

      await goToTab(tester, 'Дуртай');
      expect(find.text('Горхи-Тэрэлж'), findsOneWidget);
      expect(find.text('Дуртай газар алга'), findsNothing);

      await tester.tap(find.byTooltip('Дуртайгаас хасах'));
      await tester.pumpAndSettle();
      expect(find.text('Дуртай газар алга'), findsOneWidget);
      expect(find.text('«Горхи-Тэрэлж» хасагдлаа'), findsOneWidget);
      expect(favoriteIds.value, isEmpty);

      await tester.tap(find.text('Буцаах'));
      await tester.pumpAndSettle();
      expect(favoriteIds.value, {'terelj'});
      expect(find.text('Горхи-Тэрэлж'), findsOneWidget);
    });

    testWidgets('a favourite opens its detail from the favourites tab', (
      tester,
    ) async {
      await openApp(tester);
      setFavorite('khuvsgul', true);
      await goToTab(tester, 'Дуртай');
      await tester.tap(find.text('Хөвсгөл нуур'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('900 км'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Дуртай газрууд'), findsOneWidget);
    });

    testWidgets('empty state is shown with no favourites', (tester) async {
      await openApp(tester);
      await goToTab(tester, 'Дуртай');
      expect(find.text('Дуртай газар алга'), findsOneWidget);
    });
  });

  group('ratings', () {
    testWidgets('rating a bundled place updates the detail page', (
      tester,
    ) async {
      await openApp(tester);
      await tester.tap(find.byType(PlaceCard).first);
      await tester.pumpAndSettle();
      expect(find.text('Энэ газрыг үнэлэх'), findsOneWidget);
      await rate(tester, 4);
      expect(find.text('Таны үнэлгээ: 4/5'), findsOneWidget);
      expect(find.text('(129 үнэлгээ)'), findsOneWidget);
      expect(find.text('«Горхи-Тэрэлж»-д 4 од өглөө'), findsOneWidget);
    });

    testWidgets('changing a rating replaces it rather than adding another', (
      tester,
    ) async {
      await openApp(tester);
      await tester.tap(find.byType(PlaceCard).first);
      await tester.pumpAndSettle();
      await rate(tester, 5);
      await rate(tester, 2);
      expect(find.text('Таны үнэлгээ: 2/5'), findsOneWidget);
      expect(find.text('(129 үнэлгээ)'), findsOneWidget);
    });

    testWidgets(
      'a new place goes from "Шинэ" to its first rating on the card',
      (tester) async {
        await openApp(tester, height: 3000, extraPlaces: [userPlace()]);
        expect(find.text('Шинэ'), findsOneWidget);
        await tester.tap(find.text('Тест нуур'));
        await tester.pumpAndSettle();
        expect(find.text('Шинэ газар — үнэлгээ хараахан алга'), findsOneWidget);
        await rate(tester, 4);
        expect(find.text('(1 үнэлгээ)'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Шинэ'), findsNothing);
        expect(find.text('4.0'), findsOneWidget);
      },
    );

    testWidgets('sorting by rating reorders the grid live after a rating', (
      tester,
    ) async {
      await openApp(tester, height: 3000, extraPlaces: [userPlace()]);
      expect(cardIds(tester).last, 'user-1');

      await openFilter(tester);
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Үнэлгээгээр эрэмбэлэх'),
      );
      await tester.pumpAndSettle();
      await closeFilter(tester);
      expect(find.widgetWithText(InputChip, 'Үнэлгээгээр'), findsOneWidget);
      // Highest bundled average first; the unrated newcomer is last.
      expect(cardIds(tester).first, 'khuvsgul');
      expect(cardIds(tester).last, 'user-1');

      await tester.tap(find.text('Тест нуур'));
      await tester.pumpAndSettle();
      await rate(tester, 5);
      await tester.pageBack();
      await tester.pumpAndSettle();
      // A lone 5-star beats every bundled average (≤ 4.9).
      expect(cardIds(tester).first, 'user-1');
      expect(cardIds(tester), hasLength(11));
    });

    testWidgets('one 1-star rating drops the top place below the others', (
      tester,
    ) async {
      await openApp(tester, height: 3000);
      await openFilter(tester);
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Үнэлгээгээр эрэмбэлэх'),
      );
      await tester.pumpAndSettle();
      await closeFilter(tester);
      expect(cardIds(tester).first, 'khuvsgul');
      expect(cardIds(tester).last, isNot('khuvsgul'));

      await tester.tap(find.byType(PlaceCard).first);
      await tester.pumpAndSettle();
      await rate(tester, 1);
      // 4.9 over 342 votes, one star: still shown as 342 + 1 votes.
      expect(find.text('(343 үнэлгээ)'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // (4.9 × 10 + 1) / 11 ≈ 4.5 — under every other bundled place (≥ 4.6).
      final ids = cardIds(tester);
      expect(ids.last, 'khuvsgul');
      expect(ids.first, 'altai');
      expect(ids, hasLength(10));
    });

    testWidgets('sorting keeps catalogue order among equal ratings', (
      tester,
    ) async {
      await openApp(tester, height: 3000);
      await openFilter(tester);
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Үнэлгээгээр эрэмбэлэх'),
      );
      await tester.pumpAndSettle();
      await closeFilter(tester);
      final ids = cardIds(tester);
      // 4.9 / 4.9, then the 4.8s in catalogue order.
      expect(ids.take(2), ['khuvsgul', 'altai']);
      expect(ids.indexOf('khongor'), lessThan(ids.indexOf('orkhon')));
      expect(ids.indexOf('orkhon'), lessThan(ids.indexOf('terkhiin')));
    });
  });

  group('season filter', () {
    testWidgets('shows only places for the chosen season and a chip', (
      tester,
    ) async {
      await openApp(tester);
      await openFilter(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Хавар'));
      await tester.pumpAndSettle();
      await closeFilter(tester);
      expect(cardIds(tester), ['tsagaan_suvarga']);
      expect(find.widgetWithText(InputChip, 'Хавар'), findsOneWidget);
    });

    testWidgets('a season with no places shows the empty message', (
      tester,
    ) async {
      await openApp(tester);
      await openFilter(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Өвөл'));
      await tester.pumpAndSettle();
      await closeFilter(tester);
      expect(find.byType(PlaceCard), findsNothing);
      expect(find.text('Энэ улиралд тохирох газар алга'), findsOneWidget);
    });

    testWidgets('"Бүгд" and the chip clear the filter', (tester) async {
      await openApp(tester, height: 3000);
      await openFilter(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Намар'));
      await tester.pumpAndSettle();
      await closeFilter(tester);
      expect(cardIds(tester), ['khongor', 'khustai']);

      await tester.tap(find.byTooltip('Улирлын шүүлтүүрийг арилгах'));
      await tester.pumpAndSettle();
      expect(cardIds(tester), hasLength(10));
    });
  });

  group('filter sheet', () {
    testWidgets('is modal over the navigation rail too', (tester) async {
      await openApp(tester, width: 800, height: 900);
      await openFilter(tester);
      expect(find.widgetWithText(FilledButton, 'Болсон'), findsOneWidget);

      // The rail is covered by the sheet's barrier: tapping it only dismisses
      // the sheet and does not switch tab.
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('Дуртай'),
        ),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Болсон'), findsNothing);
      expect(find.text('Дуртай газар алга'), findsNothing);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('closes with "Болсон" on a phone and on a wide screen', (
      tester,
    ) async {
      for (final width in [390.0, 1000.0]) {
        await openApp(tester, width: width, height: 900);
        await openFilter(tester);
        expect(find.widgetWithText(FilledButton, 'Болсон'), findsOneWidget);
        await closeFilter(tester);
        expect(find.widgetWithText(FilledButton, 'Болсон'), findsNothing);
        expect(find.byType(GridView), findsOneWidget);
      }
    });
  });

  group('sort chip', () {
    testWidgets('its delete button turns the rating sort off', (tester) async {
      await openApp(tester, height: 3000);
      await openFilter(tester);
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Үнэлгээгээр эрэмбэлэх'),
      );
      await tester.pumpAndSettle();
      await closeFilter(tester);
      expect(cardIds(tester).first, 'khuvsgul');
      await tester.tap(find.byTooltip('Эрэмбийг арилгах'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, 'Үнэлгээгээр'), findsNothing);
      expect(cardIds(tester).first, 'terelj');
    });
  });

  group('search', () {
    testWidgets('finds a destination by name and opens it', (tester) async {
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
    });

    testWidgets('matches by season too', (tester) async {
      await openApp(tester);
      await tester.tap(find.byTooltip('Хайх'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Хавар');
      await tester.pumpAndSettle();
      expect(find.text('Цагаан суварга'), findsOneWidget);
      expect(find.text('Горхи-Тэрэлж'), findsNothing);
    });

    testWidgets('reports no results and clearing restores the list', (
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
      expect(find.byType(ListTile), findsWidgets);
    });
  });
}
