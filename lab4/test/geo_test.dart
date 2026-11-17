import 'package:flutter_test/flutter_test.dart';
import 'package:travel_mn/utils/geo.dart';

void main() {
  group('haversineKm', () {
    test('is zero for the same point', () {
      expect(haversineKm(47.9189, 106.9176, 47.9189, 106.9176), 0);
    });

    test('is symmetric', () {
      final a = haversineKm(47.9189, 106.9176, 51.02045, 100.47857);
      final b = haversineKm(51.02045, 100.47857, 47.9189, 106.9176);
      expect(a, closeTo(b, 1e-9));
    });

    test('one degree of latitude is about 111 km', () {
      expect(haversineKm(0, 0, 1, 0), closeTo(111.2, 0.5));
    });

    test(
      'Ulaanbaatar to Khuvsgul lake is roughly 570 km as the crow flies',
      () {
        expect(
          haversineKm(ubLatitude, ubLongitude, 51.02045, 100.47857),
          inInclusiveRange(540, 600),
        );
      },
    );
  });

  group('distanceFromUbKm', () {
    test('is 0 in Ulaanbaatar and rounds to a whole number', () {
      expect(distanceFromUbKm(ubLatitude, ubLongitude), 0);
      expect(distanceFromUbKm(47.88843, 107.42282), isA<int>());
      // Terelj is about 40 km as the crow flies.
      expect(distanceFromUbKm(47.88843, 107.42282), inInclusiveRange(35, 45));
    });
  });

  group('formatCoordinates', () {
    test('uses five decimals, latitude first', () {
      expect(formatCoordinates(47.9189, 106.9176), '47.91890, 106.91760');
    });

    test('rounds rather than truncates', () {
      expect(formatCoordinates(47.123456, 106.987654), '47.12346, 106.98765');
    });
  });
}
