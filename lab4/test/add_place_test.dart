import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:travel_mn/data/places.dart';
import 'package:travel_mn/screens/add_place_screen.dart';
import 'package:travel_mn/screens/detail_screen.dart';
import 'package:travel_mn/screens/map_picker_screen.dart';

import 'helpers.dart';

late FakeImagePicker picker;

Finder button(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

Future<void> openForm(WidgetTester tester) async {
  picker = installFakeImagePicker();
  await openApp(tester, height: 2400);
  await tester.tap(find.byTooltip('Газар нэмэх'));
  await tester.pumpAndSettle();
  expect(find.byType(AddPlaceScreen), findsOneWidget);
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fillRequired(
  WidgetTester tester, {
  String name = 'Тест нуур',
}) async {
  await fill(tester, 'Газрын нэр', name);
  await fill(tester, 'Аймаг / байршил', 'Төв аймаг');
  await fill(tester, 'Тайлбар', 'Маш сайхан газар, заавал очоорой.');
}

void main() {
  group('validation', () {
    testWidgets('empty required fields are flagged and nothing is saved', (
      tester,
    ) async {
      await openForm(tester);
      await tap(tester, find.text('Хадгалах'));
      expect(find.text('Заавал бөглөнө үү'), findsNWidgets(3));
      expect(find.byType(AddPlaceScreen), findsOneWidget);
      expect(places.where((p) => p.isUserAdded), isEmpty);
    });

    testWidgets('too-short values show the minimum length', (tester) async {
      await openForm(tester);
      await fill(tester, 'Газрын нэр', 'А');
      await fill(tester, 'Тайлбар', 'богино');
      await tap(tester, find.text('Хадгалах'));
      expect(find.text('Хамгийн багадаа 2 тэмдэгт'), findsWidgets);
      expect(find.text('Хамгийн багадаа 10 тэмдэгт'), findsOneWidget);
    });

    testWidgets('distance must be a whole number from 1 to 5000', (
      tester,
    ) async {
      await openForm(tester);
      await fillRequired(tester);
      for (final (text, message) in [
        ('abc', 'Бүхэл тоо оруулна уу'),
        ('1.5', 'Бүхэл тоо оруулна уу'),
        ('0', 'Зай 1–5000 км байх ёстой'),
        ('5001', 'Зай 1–5000 км байх ёстой'),
      ]) {
        await fill(tester, 'Улаанбаатараас зай (км)', text);
        await tap(tester, find.text('Хадгалах'));
        expect(find.text(message), findsOneWidget, reason: text);
        expect(find.byType(AddPlaceScreen), findsOneWidget, reason: text);
      }
    });
  });

  group('saving', () {
    testWidgets('a valid place is added to the grid with a snackbar', (
      tester,
    ) async {
      await openForm(tester);
      await fillRequired(tester);
      await fill(tester, 'Улаанбаатараас зай (км)', '120');
      await tap(tester, find.widgetWithText(ChoiceChip, 'Хавар'));
      await tap(tester, find.text('Хадгалах'));

      expect(find.byType(AddPlaceScreen), findsNothing);
      expect(find.text('«Тест нуур» нэмэгдлээ'), findsOneWidget);
      expect(find.text('Тест нуур'), findsOneWidget);
      expect(find.text('Шинэ'), findsOneWidget);

      final added = places.singleWhere((p) => p.isUserAdded);
      expect(added.bestSeason, 'Хавар');
      expect(added.distanceKm, 120);
      expect(added.rating, 0);
      expect(added.imageBytes, isEmpty);

      await tester.tap(find.text('Тест нуур'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('120 км'), findsOneWidget);
    });

    testWidgets('the distance is optional and shows a dash when omitted', (
      tester,
    ) async {
      await openForm(tester);
      await fillRequired(tester);
      await tap(tester, find.text('Хадгалах'));
      await tester.tap(find.text('Тест нуур'));
      await tester.pumpAndSettle();
      expect(find.text('–'), findsOneWidget);
    });

    testWidgets('leaving with back adds nothing', (tester) async {
      await openForm(tester);
      await fillRequired(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(AddPlaceScreen), findsNothing);
      expect(find.text('Тест нуур'), findsNothing);
      expect(places.where((p) => p.isUserAdded), isEmpty);
    });
  });

  group('photos', () {
    testWidgets('gallery pick of several photos asks for at most 3', (
      tester,
    ) async {
      await openForm(tester);
      expect(find.text('Зураг (заавал биш, 0/3)'), findsOneWidget);
      picker.multiResult = [
        FakeImagePicker.file('a.png'),
        FakeImagePicker.file('b.png'),
      ];
      await tap(tester, find.text('Галерейгаас'));
      expect(picker.lastMultiLimit, 3);
      expect(find.text('Зураг (заавал биш, 2/3)'), findsOneWidget);
    });

    testWidgets('photos can be added until 3, then the buttons are disabled', (
      tester,
    ) async {
      await openForm(tester);
      picker.multiResult = [
        FakeImagePicker.file('a.png'),
        FakeImagePicker.file('b.png'),
      ];
      await tap(tester, find.text('Галерейгаас'));
      // One slot left: the app falls back to a single-photo pick.
      picker.singleResult = FakeImagePicker.file('c.png');
      await tap(tester, find.text('Зураг нэмэх'));
      expect(find.text('Зураг (заавал биш, 3/3)'), findsOneWidget);
      expect(
        tester.widget<ButtonStyleButton>(button('Зураг нэмэх')).onPressed,
        isNull,
      );
      expect(
        tester.widget<ButtonStyleButton>(button('Камераар')).onPressed,
        isNull,
      );
      expect(find.byTooltip('Зургийг хасах'), findsNWidgets(3));
    });

    testWidgets('a fourth photo is rejected when the picker returns too many', (
      tester,
    ) async {
      await openForm(tester);
      picker.multiResult = [
        for (final n in ['a', 'b', 'c', 'd']) FakeImagePicker.file('$n.png'),
      ];
      await tap(tester, find.text('Галерейгаас'));
      expect(find.text('Зураг (заавал биш, 3/3)'), findsOneWidget);
      expect(find.text('Дээд тал нь 3 зураг оруулж болно'), findsOneWidget);
    });

    testWidgets('a photo can be removed to make room again', (tester) async {
      await openForm(tester);
      picker.multiResult = [
        for (final n in ['a', 'b', 'c']) FakeImagePicker.file('$n.png'),
      ];
      await tap(tester, find.text('Галерейгаас'));
      await tap(tester, find.byTooltip('Зургийг хасах').first);
      expect(find.text('Зураг (заавал биш, 2/3)'), findsOneWidget);
      expect(
        tester.widget<ButtonStyleButton>(button('Зураг нэмэх')).onPressed,
        isNotNull,
      );
    });

    testWidgets('the camera adds one photo', (tester) async {
      await openForm(tester);
      picker.cameraResult = FakeImagePicker.file('cam.png');
      await tap(tester, find.text('Камераар'));
      expect(picker.sources, [ImageSource.camera]);
      expect(find.text('Зураг (заавал биш, 1/3)'), findsOneWidget);
    });

    testWidgets('cancelling the picker changes nothing', (tester) async {
      await openForm(tester);
      picker.multiResult = [];
      await tap(tester, find.text('Галерейгаас'));
      expect(find.text('Зураг (заавал биш, 0/3)'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a picker failure is reported, not thrown', (tester) async {
      await openForm(tester);
      picker.fail = true;
      await tap(tester, find.text('Галерейгаас'));
      expect(find.text('Зураг сонгож чадсангүй'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no camera button where there is no camera', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await openForm(tester);
        expect(find.text('Камераар'), findsNothing);
        expect(find.text('Галерейгаас'), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets(
      'saving with 3 photos gives a swipeable gallery on the detail',
      (tester) async {
        await openForm(tester);
        await fillRequired(tester);
        picker.multiResult = [
          for (final n in ['a', 'b', 'c']) FakeImagePicker.file('$n.png'),
        ];
        await tap(tester, find.text('Галерейгаас'));
        await tap(tester, find.text('Хадгалах'));
        expect(
          places.singleWhere((p) => p.isUserAdded).imageBytes,
          hasLength(3),
        );

        await tester.tap(find.text('Тест нуур'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('photo-gallery')), findsOneWidget);
        expect(find.text('1 / 3'), findsOneWidget);
        await tester.drag(
          find.byKey(const Key('photo-gallery')),
          const Offset(-300, 0),
        );
        await tester.pumpAndSettle();
        expect(find.text('2 / 3'), findsOneWidget);
        await tester.drag(
          find.byKey(const Key('photo-gallery')),
          const Offset(-300, 0),
        );
        await tester.pumpAndSettle();
        expect(find.text('3 / 3'), findsOneWidget);
        await tester.drag(
          find.byKey(const Key('photo-gallery')),
          const Offset(300, 0),
        );
        await tester.pumpAndSettle();
        expect(find.text('2 / 3'), findsOneWidget);
      },
    );

    testWidgets(
      'a picker that ignores the limit still keeps at most 3 photos',
      (tester) async {
        await openForm(tester);
        picker.multiResult = [
          for (final n in ['a', 'b', 'c', 'd', 'e'])
            FakeImagePicker.file('$n.png'),
        ];
        await tap(tester, find.text('Галерейгаас'));
        expect(find.text('Зураг (заавал биш, 3/3)'), findsOneWidget);
        expect(find.text('Дээд тал нь 3 зураг оруулж болно'), findsOneWidget);

        // Remove two, then pick five again: only the two free slots fill.
        await tap(tester, find.byTooltip('Зургийг хасах').first);
        await tap(tester, find.byTooltip('Зургийг хасах').first);
        expect(find.text('Зураг (заавал биш, 1/3)'), findsOneWidget);
        await tap(tester, find.text('Зураг нэмэх'));
        expect(find.text('Зураг (заавал биш, 3/3)'), findsOneWidget);
      },
    );

    testWidgets('overlapping picks are blocked while the picker is open', (
      tester,
    ) async {
      await openForm(tester);
      picker.gate = Completer<void>();
      picker.multiResult = [
        for (final n in ['a', 'b']) FakeImagePicker.file('$n.png'),
      ];
      await tester.tap(find.text('Галерейгаас'));
      await tester.pump();
      // While the picker is open the buttons are disabled; a second tap is a no-op.
      expect(
        tester.widget<ButtonStyleButton>(button('Галерейгаас')).onPressed,
        isNull,
      );
      await tester.tap(find.text('Галерейгаас'), warnIfMissed: false);
      await tester.pump();
      expect(picker.sources, hasLength(1));

      picker.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Зураг (заавал биш, 2/3)'), findsOneWidget);
      // Free again afterwards.
      expect(
        tester.widget<ButtonStyleButton>(button('Зураг нэмэх')).onPressed,
        isNotNull,
      );
    });

    testWidgets(
      'the gallery can be dragged with a mouse and has arrow buttons',
      (tester) async {
        await openForm(tester);
        await fillRequired(tester);
        picker.multiResult = [
          for (final n in ['a', 'b', 'c']) FakeImagePicker.file('$n.png'),
        ];
        await tap(tester, find.text('Галерейгаас'));
        await tap(tester, find.text('Хадгалах'));
        await tester.tap(find.text('Тест нуур'));
        await tester.pumpAndSettle();

        IconButton arrow(String tooltip) => tester.widget<IconButton>(
          find
              .ancestor(
                of: find.byTooltip(tooltip),
                matching: find.byType(IconButton),
              )
              .first,
        );

        // First photo: nothing before it.
        expect(find.text('1 / 3'), findsOneWidget);
        expect(arrow('Өмнөх зураг').onPressed, isNull);
        expect(arrow('Дараах зураг').onPressed, isNotNull);

        // Mouse drag (web / desktop) turns the page.
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('photo-gallery'))),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.moveBy(const Offset(-120, 0));
        await gesture.moveBy(const Offset(-200, 0));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(find.text('2 / 3'), findsOneWidget);

        await tester.tap(find.byTooltip('Дараах зураг'));
        await tester.pumpAndSettle();
        expect(find.text('3 / 3'), findsOneWidget);
        expect(arrow('Дараах зураг').onPressed, isNull);

        await tester.tap(find.byTooltip('Өмнөх зураг'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Өмнөх зураг'));
        await tester.pumpAndSettle();
        expect(find.text('1 / 3'), findsOneWidget);
        expect(arrow('Өмнөх зураг').onPressed, isNull);
      },
    );

    testWidgets('a place with one photo has no arrow buttons', (tester) async {
      await openApp(tester, height: 3000, extraPlaces: [userPlace(images: 1)]);
      await tester.tap(find.text('Тест нуур'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Өмнөх зураг'), findsNothing);
      expect(find.byTooltip('Дараах зураг'), findsNothing);
    });
  });

  group('location', () {
    testWidgets('the map picker opens and closes without picking', (
      tester,
    ) async {
      await openForm(tester);
      await tap(tester, find.text('Газрын зураг дээр байршил тэмдэглэх'));
      expect(find.byType(MapPickerScreen), findsOneWidget);
      expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(AddPlaceScreen), findsOneWidget);
    });
  });
}
