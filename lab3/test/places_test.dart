import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/data/places.dart';

void main() {
  test(
    'ten unique destinations have complete data and bundled photographs',
    () {
      expect(places, hasLength(10));
      expect(places.map((place) => place.id).toSet(), hasLength(10));
      for (final place in places) {
        expect(place.name, isNotEmpty);
        expect(place.region, isNotEmpty);
        expect(place.description, isNotEmpty);
        expect(place.rating, inInclusiveRange(0, 5));
        expect(place.distanceKm, greaterThan(0));
        expect(place.bestSeason, isNotEmpty);
        final photo = File(place.image);
        expect(photo.existsSync(), isTrue, reason: place.image);
        expect(photo.readAsBytesSync().take(2), [0xff, 0xd8]);
      }
    },
  );
}
