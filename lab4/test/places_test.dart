import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/data/places.dart';

void main() {
  test('there are exactly 10 bundled destinations with unique ids', () {
    expect(places, hasLength(10));
    expect({for (final p in places) p.id}, hasLength(10));
    expect({for (final p in places) p.name}, hasLength(10));
  });

  test('every destination lies inside Mongolia', () {
    for (final p in places) {
      expect(p.hasLocation, isTrue, reason: p.id);
      expect(p.latitude!, inInclusiveRange(41.5, 52.2), reason: p.id);
      expect(p.longitude!, inInclusiveRange(87.7, 119.9), reason: p.id);
    }
  });

  test('every destination has a valid season, rating and copy', () {
    for (final p in places) {
      expect(seasons, contains(p.bestSeason), reason: p.id);
      expect(p.rating, inInclusiveRange(1, 5), reason: p.id);
      expect(p.ratingCount, greaterThan(0), reason: p.id);
      expect(p.distanceKm, greaterThan(0), reason: p.id);
      expect(p.region.trim(), isNotEmpty, reason: p.id);
      expect(p.description.trim().length, greaterThan(20), reason: p.id);
    }
  });

  test('every bundled image exists and is a JPEG', () {
    final paths = {
      for (final p in places) p.image,
      'assets/images/placeholder.jpg',
    };
    for (final path in paths) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      final head = file.readAsBytesSync().take(3).toList();
      expect(head, [0xFF, 0xD8, 0xFF], reason: '$path is not a JPEG');
    }
  });

  test('photo credits are shipped with the images', () {
    expect(File('assets/PHOTO_CREDITS.txt').existsSync(), isTrue);
  });
}
