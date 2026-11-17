import 'dart:math' as math;

/// Ulaanbaatar (Sükhbaatar Square area), the origin for distances.
const ubLatitude = 47.9189;
const ubLongitude = 106.9176;

/// Great-circle (straight-line) distance in kilometres.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusKm * math.asin(math.sqrt(a));
}

/// Straight-line distance from Ulaanbaatar, rounded to whole kilometres.
int distanceFromUbKm(double lat, double lng) =>
    haversineKm(ubLatitude, ubLongitude, lat, lng).round();

String formatCoordinates(double lat, double lng) =>
    '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
