import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Most photographs a user may attach to a destination they add.
const maxUserImages = 3;

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.region,
    required this.image,
    required this.description,
    required this.rating,
    this.ratingCount = 0,
    required this.distanceKm,
    required this.bestSeason,
    this.latitude,
    this.longitude,
    this.imageBytes = const [],
  }) : assert(rating >= 0 && rating <= 5),
       assert(distanceKm >= 0),
       assert(imageBytes.length <= maxUserImages);

  final String id;
  final String name;
  final String region;

  /// Bundled asset used when the place has no photographs of its own.
  final String image;
  final String description;

  /// Average of [ratingCount] earlier ratings; 0 means "not rated yet".
  final double rating;
  final int ratingCount;

  /// Approximate road distance from Ulaanbaatar; routes can vary. For places
  /// added by the user it may be a straight-line estimate or 0 (unknown).
  final int distanceKm;
  final String bestSeason;
  final double? latitude;
  final double? longitude;

  /// Photographs picked by the user (at most [maxUserImages]).
  final List<Uint8List> imageBytes;

  bool get hasLocation => latitude != null && longitude != null;

  /// Added through the form rather than bundled with the app.
  bool get isUserAdded => id.startsWith('user-');

  /// Cover photograph: the first picked image, otherwise the bundled asset.
  ImageProvider get imageProvider =>
      imageBytes.isNotEmpty ? MemoryImage(imageBytes.first) : AssetImage(image);

  /// Every photograph in the gallery (the bundled asset when none picked).
  List<ImageProvider> get imageProviders => imageBytes.isNotEmpty
      ? [for (final bytes in imageBytes) MemoryImage(bytes)]
      : [AssetImage(image)];
}
