class Place {
  const Place({
    required this.id,
    required this.name,
    required this.region,
    required this.image,
    required this.description,
    required this.rating,
    required this.distanceKm,
    required this.bestSeason,
  }) : assert(rating >= 0 && rating <= 5),
       assert(distanceKm >= 0);

  final String id;
  final String name;
  final String region;
  final String image;
  final String description;
  final double rating;

  /// Approximate road distance from Ulaanbaatar; routes can vary.
  final int distanceKm;
  final String bestSeason;
}
