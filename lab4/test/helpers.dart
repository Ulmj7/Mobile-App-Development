import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:travel_mn/data/places.dart';
import 'package:travel_mn/main.dart';
import 'package:travel_mn/models/place.dart';
import 'package:travel_mn/state/app_state.dart';
import 'package:travel_mn/widgets/osm_map.dart';
import 'package:travel_mn/widgets/place_card.dart';

/// A valid 1×1 PNG, so `Image.memory` has something real to decode.
final Uint8List tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

/// Serves a blank tile so the map never touches the network.
class FakeTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(tinyPng);
}

/// Stands in for the platform image picker.
class FakeImagePicker extends ImagePickerPlatform
    with MockPlatformInterfaceMixin {
  /// What the next gallery (multi) pick returns.
  List<XFile> multiResult = [];

  /// What the next single gallery pick returns.
  XFile? singleResult;

  /// What the next camera pick returns.
  XFile? cameraResult;

  /// Throw instead of returning, to exercise the error path.
  bool fail = false;

  /// When set, every pick waits for it — lets a test overlap picker calls.
  Completer<void>? gate;

  final sources = <ImageSource>[];
  int? lastMultiLimit;

  static XFile file(String name) =>
      XFile.fromData(tinyPng, name: name, mimeType: 'image/png');

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    sources.add(source);
    await gate?.future;
    if (fail) throw StateError('picker failed');
    return source == ImageSource.camera ? cameraResult : singleResult;
  }

  @override
  Future<List<XFile>> getMultiImageWithOptions({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    sources.add(ImageSource.gallery);
    lastMultiLimit = options.limit;
    await gate?.future;
    if (fail) throw StateError('picker failed');
    return multiResult;
  }
}

FakeImagePicker installFakeImagePicker() {
  final picker = FakeImagePicker();
  ImagePickerPlatform.instance = picker;
  return picker;
}

/// A destination as the add-place form would create it.
Place userPlace({
  String id = 'user-1',
  String name = 'Тест нуур',
  int images = 0,
}) => Place(
  id: id,
  name: name,
  region: 'Төв аймаг',
  image: 'assets/images/placeholder.jpg',
  description: 'Туршилтын газрын тайлбар.',
  rating: 0,
  ratingCount: 0,
  distanceKm: 0,
  bestSeason: 'Зун',
  imageBytes: [for (var i = 0; i < images; i++) tinyPng],
);

/// Boots the app on a fresh state at the given logical size.
Future<void> openApp(
  WidgetTester tester, {
  double width = 390,
  double height = 844,
  double textScale = 1,
  Brightness brightness = Brightness.light,
  bool loggedIn = true,
  Iterable<Place> extraPlaces = const [],
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  resetAppState(loggedIn: loggedIn);
  extraPlaces.forEach(addPlace);
  tileProviderOverride = FakeTileProvider();
  addTearDown(() {
    tileProviderOverride = null;
    resetAppState();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(const TravelApp());
  await tester.pumpAndSettle();
}

/// Ids of the cards currently in the grid, in display order.
List<String> cardIds(WidgetTester tester) => [
  for (final card in tester.widgetList<PlaceCard>(find.byType(PlaceCard)))
    card.place.id,
];

/// Opens a bottom-navigation / rail destination by its label.
Future<void> goToTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is NavigationBar || w is NavigationRail,
      ),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

/// Types into the field whose label is [label].
Future<void> fill(WidgetTester tester, String label, String text) async {
  final field = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pump();
}
