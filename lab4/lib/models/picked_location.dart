import '../utils/geo.dart';

/// A point chosen on the map, with whatever the reverse geocoder knew about it.
class PickedLocation {
  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
    this.region,
  });

  final double latitude;
  final double longitude;

  /// Full human-readable address.
  final String? address;

  /// Short name of the spot (lake, village, ...), if the geocoder had one.
  final String? name;

  /// Province or city (аймаг / хот).
  final String? region;

  String get coordinates => formatCoordinates(latitude, longitude);

  PickedLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? name,
    String? region,
  }) => PickedLocation(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    address: address ?? this.address,
    name: name ?? this.name,
    region: region ?? this.region,
  );
}
