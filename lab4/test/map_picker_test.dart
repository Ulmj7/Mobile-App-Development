import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travel_mn/screens/map_picker_screen.dart';
import 'package:travel_mn/services/geocoding_service.dart';

import 'helpers.dart';

http.Response _json(Object body) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Map<String, String> _place(String name, String lat, String lon) => {
  'lat': lat,
  'lon': lon,
  'name': name,
  'display_name': '$name, Монгол',
};

/// Every request the fake Nominatim saw, e.g. `/search`.
late List<Uri> requests;
Iterable<Uri> get searches => requests.where((u) => u.path == '/search');

void useGeocoding(Future<http.Response> Function(http.Request) handler) {
  requests = [];
  Geocoding.configureForTest(
    client: MockClient((req) {
      requests.add(req.url);
      return handler(req);
    }),
    gap: const Duration(milliseconds: 1),
  );
}

Future<void> openPicker(
  WidgetTester tester, {
  double width = 390,
  double height = 844,
  double textScale = 1,
}) async {
  installFakeImagePicker();
  await openApp(tester, width: width, height: height, textScale: textScale);
  await tester.tap(find.byTooltip('Газар нэмэх'));
  await tester.pumpAndSettle();
  final link = find.text('Газрын зураг дээр байршил тэмдэглэх');
  await tester.ensureVisible(link);
  await tester.tap(link);
  await tester.pumpAndSettle();
  expect(find.byType(MapPickerScreen), findsOneWidget);
}

/// Progress indicators never settle, so advance time in small steps.
Future<void> pumpFor(WidgetTester tester, [int ms = 600]) async {
  for (var i = 0; i < ms ~/ 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> tapMap(WidgetTester tester) async {
  await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
  await pumpFor(tester);
}

final searchSpinner = find.byWidgetPredicate(
  (w) => w is CircularProgressIndicator && w.semanticsLabel == 'Хайж байна',
);

void main() {
  tearDown(Geocoding.configureForTest);

  group('search', () {
    testWidgets('the arrow button searches; several hits are listed and one '
        'can be chosen', (tester) async {
      useGeocoding(
        (req) async => _json([
          _place('Хөвсгөл нуур', '51.0', '100.5'),
          _place('Хөвсгөл аймаг', '50.5', '100.1'),
        ]),
      );
      await openPicker(tester);
      await tester.enterText(find.byType(TextField), 'Хөвсгөл');
      await tester.tap(find.byTooltip('Хайх'));
      await pumpFor(tester);

      expect(searches, hasLength(1));
      expect(searches.single.queryParameters['q'], 'Хөвсгөл');
      expect(find.widgetWithText(ListTile, 'Хөвсгөл нуур'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Хөвсгөл аймаг'), findsOneWidget);
      expect(find.byType(Divider), findsWidgets);

      await tester.tap(find.widgetWithText(ListTile, 'Хөвсгөл аймаг'));
      await pumpFor(tester);
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Хөвсгөл аймаг'), findsOneWidget); // info panel title
    });

    testWidgets('Enter searches too, and a second submit while searching is '
        'ignored', (tester) async {
      final gate = Completer<void>();
      useGeocoding((req) async {
        await gate.future;
        return _json([
          _place('A', '47.0', '106.0'),
          _place('B', '48.0', '107.0'),
        ]);
      });
      await openPicker(tester);
      await tester.enterText(find.byType(TextField), 'нуур');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await pumpFor(tester);
      expect(searchSpinner, findsOneWidget);
      // The arrow button is replaced by the spinner; Enter again does nothing.
      expect(find.byTooltip('Хайх'), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await pumpFor(tester);
      expect(searches, hasLength(1));

      gate.complete();
      await pumpFor(tester);
      expect(searchSpinner, findsNothing);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('clear empties the field and the result list', (tester) async {
      useGeocoding(
        (req) async =>
            _json([_place('A', '47.0', '106.0'), _place('B', '48.0', '107.0')]),
      );
      await openPicker(tester);
      await tester.enterText(find.byType(TextField), 'нуур');
      await tester.tap(find.byTooltip('Хайх'));
      await pumpFor(tester);
      expect(find.byType(ListTile), findsNWidgets(2));

      await tester.tap(find.byTooltip('Арилгах'));
      await pumpFor(tester);
      expect(find.byType(ListTile), findsNothing);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      // An empty query is not sent.
      await tester.tap(find.byTooltip('Хайх'));
      await pumpFor(tester);
      expect(searches, hasLength(1));
    });

    testWidgets('a single hit is picked straight away', (tester) async {
      useGeocoding((req) async => _json([_place('Цэцэрлэг', '47.5', '101.5')]));
      await openPicker(tester);
      await tester.enterText(find.byType(TextField), 'Цэцэрлэг');
      await tester.tap(find.byTooltip('Хайх'));
      await pumpFor(tester);
      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Цэцэрлэг'), findsWidgets);
      expect(
        find.text('47.50000, 101.50000'),
        findsNothing,
      ); // name, not bare coordinates
      expect(searchSpinner, findsNothing);
    });

    testWidgets('no hits and failures are explained and never leave a spinner', (
      tester,
    ) async {
      useGeocoding((req) async => _json([]));
      await openPicker(tester);
      await tester.enterText(find.byType(TextField), 'ззз');
      await tester.tap(find.byTooltip('Хайх'));
      await pumpFor(tester);
      expect(find.text('Юу ч олдсонгүй. Өөр нэрээр хайна уу.'), findsOneWidget);
      expect(searchSpinner, findsNothing);

      // The transport fails (the service turns any such error into a message).
      useGeocoding((req) async => throw StateError('boom'));
      await tester.enterText(find.byType(TextField), 'жишээ');
      await tester.tap(find.byTooltip('Хайх'));
      await pumpFor(tester);
      expect(
        find.text('Сүлжээнд холбогдож чадсангүй. Интернэтээ шалгана уу.'),
        findsOneWidget,
      );
      expect(searchSpinner, findsNothing);
      // ...and the user can try again.
      expect(find.byTooltip('Хайх'), findsOneWidget);
    });

    testWidgets('a late search answer after a map tap does not move the pin', (
      tester,
    ) async {
      final gate = Completer<void>();
      useGeocoding((req) async {
        if (req.url.path == '/search') {
          await gate.future;
          return _json([_place('Хайлтын газар', '51.0', '100.5')]);
        }
        return _json(_place('Товшсон газар', '47.0', '106.0'));
      });
      await openPicker(tester);
      await tester.enterText(find.byType(TextField), 'хол');
      await tester.tap(find.byTooltip('Хайх'));
      await pumpFor(tester);
      expect(searchSpinner, findsOneWidget);

      // The user gives up waiting and taps the map instead.
      await tapMap(tester);
      expect(searchSpinner, findsNothing);
      // (Nominatim requests are queued, so the address waits behind the search.)
      expect(find.text('Хаяг хайж байна…'), findsOneWidget);

      // Now the slow search answers; the tapped point stays and gets its name.
      gate.complete();
      await pumpFor(tester, 1500);
      expect(find.text('Товшсон газар'), findsOneWidget);
      expect(find.text('Хайлтын газар'), findsNothing);
      expect(find.byType(ListTile), findsNothing);
      expect(searchSpinner, findsNothing);
    });
  });

  group('reverse geocoding by tapping the map', () {
    testWidgets('shows the resolved name and the distance from Ulaanbaatar', (
      tester,
    ) async {
      useGeocoding(
        (req) async => _json(_place('Товшсон газар', '47.0', '106.0')),
      );
      await openPicker(tester);
      await tapMap(tester);
      expect(find.text('Товшсон газар'), findsOneWidget);
      expect(find.textContaining('Улаанбаатараас ~'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('a failed lookup keeps the point and stops the progress bar', (
      tester,
    ) async {
      useGeocoding((req) async => throw StateError('boom'));
      await openPicker(tester);
      await tapMap(tester);
      expect(
        find.text('Сүлжээнд холбогдож чадсангүй. Интернэтээ шалгана уу.'),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      // The point is still chosen and can be confirmed.
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });
  });

  group('small screens', () {
    for (final (w, h) in [(320.0, 568.0), (640.0, 320.0)]) {
      testWidgets(
        'results, long names and the keyboard fit on ${w.toInt()}×${h.toInt()} at ×1.8',
        (tester) async {
          useGeocoding(
            (req) async => _json([
              for (var i = 0; i < 5; i++)
                _place('Нэлээн урт нэртэй байршил номер $i', '4$i.0', '10$i.0'),
            ]),
          );
          await openPicker(tester, width: w, height: h, textScale: 1.8);
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          addTearDown(tester.view.resetViewInsets);
          await tester.enterText(find.byType(TextField), 'байршил');
          await tester.tap(find.byTooltip('Хайх'));
          await pumpFor(tester);
          expect(find.byType(ListTile), findsWidgets);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
