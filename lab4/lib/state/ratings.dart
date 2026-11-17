import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/place.dart';

/// The signed-in user's own star rating (1–5) per place id.
final userRatings = ValueNotifier<Map<String, int>>({});

void ratePlace(String id, int stars) {
  assert(stars >= 1 && stars <= 5);
  // A fresh map, so ValueNotifier sees a change.
  userRatings.value = {...userRatings.value, id: stars};
}

class RatingSummary {
  const RatingSummary({
    required this.average,
    required this.count,
    required this.mine,
  });

  final double average;
  final int count;

  /// The user's own rating, if any.
  final int? mine;

  bool get hasRating => count > 0;

  String get label => average.toStringAsFixed(1);
}

/// How many of a bundled place's seed ratings count towards the average once
/// the user adds their own. The seed ratings are illustrative demo data (a few
/// hundred "earlier" votes); weighting all of them would let one star move a
/// 128-vote average by less than 0.04 and the sort-by-rating list would look
/// frozen. Capping the weight keeps the lab's formula shape, (average × n +
/// mine) / (n + 1), but makes a rating visibly re-order the list.
const ratingSeedWeight = 10;

/// The place's average with the user's rating folded in. The bundled average
/// counts as at most [ratingSeedWeight] earlier ratings; the displayed count
/// still grows by one, from the place's [Place.ratingCount].
RatingSummary ratingOf(Place place, [Map<String, int>? ratings]) {
  final mine = (ratings ?? userRatings.value)[place.id];
  final baseCount = place.rating > 0 ? place.ratingCount : 0;
  if (mine == null) {
    return RatingSummary(average: place.rating, count: baseCount, mine: null);
  }
  final weight = math.min(baseCount, ratingSeedWeight);
  final average = (place.rating * weight + mine) / (weight + 1);
  return RatingSummary(average: average, count: baseCount + 1, mine: mine);
}
