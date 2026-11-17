import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/data/places.dart';
import 'package:travel_mn/models/place.dart';
import 'package:travel_mn/state/ratings.dart';

Place _place({double rating = 4.0, int count = 10}) => Place(
  id: 'x',
  name: 'X',
  region: 'R',
  image: 'assets/images/placeholder.jpg',
  description: 'd',
  rating: rating,
  ratingCount: count,
  distanceKm: 0,
  bestSeason: 'Зун',
);

void main() {
  tearDown(() => userRatings.value = {});

  test('an unrated place keeps its bundled average and count', () {
    final s = ratingOf(_place(rating: 4.5, count: 20), {});
    expect(s.average, 4.5);
    expect(s.count, 20);
    expect(s.mine, isNull);
    expect(s.hasRating, isTrue);
    expect(s.label, '4.5');
  });

  test('a brand-new place has no rating at all', () {
    final s = ratingOf(_place(rating: 0, count: 0), {});
    expect(s.hasRating, isFalse);
    expect(s.count, 0);
  });

  test('my rating is folded into the average and bumps the count', () {
    // Fewer earlier ratings than the seed cap: every one of them counts.
    final s = ratingOf(_place(rating: 4.0, count: 8), {'x': 5});
    expect(s.mine, 5);
    expect(s.count, 9);
    expect(s.average, closeTo((4.0 * 8 + 5) / 9, 1e-9));
  });

  test('a large seed count is capped at ratingSeedWeight in the average', () {
    expect(ratingSeedWeight, 10);
    final s = ratingOf(_place(rating: 4.7, count: 128), {'x': 1});
    // Shown count still grows from the real count...
    expect(s.count, 129);
    // ...but the average moves as if there were only 10 earlier ratings.
    expect(s.average, closeTo((4.7 * 10 + 1) / 11, 1e-9));
    expect(
      4.7 - s.average,
      greaterThan(0.3),
      reason: 'one star must be visible',
    );
  });

  test('exactly at the cap behaves like the plain formula', () {
    final s = ratingOf(_place(rating: 4.0, count: ratingSeedWeight), {'x': 5});
    expect(s.average, closeTo((4.0 * 10 + 5) / 11, 1e-9));
    expect(s.count, 11);
  });

  test('rating a new place makes the average equal my rating', () {
    final s = ratingOf(_place(rating: 0, count: 0), {'x': 3});
    expect(s.average, 3);
    expect(s.count, 1);
    expect(s.hasRating, isTrue);
  });

  test('ratePlace stores a fresh map so listeners fire, and replaces mine', () {
    var notified = 0;
    void listener() => notified++;
    userRatings.addListener(listener);
    addTearDown(() => userRatings.removeListener(listener));

    ratePlace('terelj', 4);
    ratePlace('terelj', 2);
    expect(userRatings.value['terelj'], 2);
    expect(notified, 2);
  });

  test('ratingOf defaults to the global user ratings', () {
    final terelj = places.firstWhere((p) => p.id == 'terelj');
    ratePlace('terelj', 1);
    final s = ratingOf(terelj);
    expect(s.mine, 1);
    expect(s.count, terelj.ratingCount + 1);
    expect(s.average, lessThan(terelj.rating));
  });
}
