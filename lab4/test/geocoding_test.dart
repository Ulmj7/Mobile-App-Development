import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travel_mn/services/geocoding_service.dart';

const _gap = Duration(milliseconds: 1);

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void _use(Future<http.Response> Function(http.Request) handler) {
  Geocoding.configureForTest(client: MockClient(handler), gap: _gap);
}

Future<GeocodingException> _failure(Future<Object?> Function() call) async {
  try {
    await call();
  } on GeocodingException catch (e) {
    return e;
  }
  fail('expected a GeocodingException');
}

void main() {
  tearDown(Geocoding.configureForTest);

  group('malformed answers', () {
    test('search skips rows without usable coordinates', () async {
      _use(
        (req) async => _json([
          {'lat': 'abc', 'lon': '100.1', 'name': 'bad lat'},
          {'lat': '47.9', 'name': 'missing lon'},
          {'lat': null, 'lon': null, 'name': 'nulls'},
          {'lat': 'NaN', 'lon': '1', 'name': 'nan'},
          'not a map',
          {'lat': '48.5', 'lon': '106.5', 'name': 'Сайн'},
        ]),
      );
      final results = await Geocoding.search('x');
      expect(results.map((r) => r.name), ['Сайн']);
    });

    test(
      'search with only malformed rows is an empty (not failed) result',
      () async {
        _use(
          (req) async => _json([
            {'lat': 'oops', 'lon': 'oops'},
          ]),
        );
        expect(await Geocoding.search('x'), isEmpty);
      },
    );

    test(
      'reverse with unusable coordinates is a friendly GeocodingException',
      () async {
        _use(
          (req) async => _json({'lat': 'x', 'lon': 'y', 'display_name': 'Z'}),
        );
        final e = await _failure(() => Geocoding.reverse(47.9, 106.9));
        expect(e.message, 'Серверийн хариуг уншиж чадсангүй.');
      },
    );
  });

  group('search', () {
    test(
      'builds a Mongolia-limited Nominatim request and parses results',
      () async {
        late http.Request seen;
        _use((req) async {
          seen = req;
          return _json([
            {
              'lat': '51.0204',
              'lon': '100.4785',
              'display_name': 'Хөвсгөл нуур, Хөвсгөл аймаг, Монгол',
              'name': 'Хөвсгөл нуур',
              'address': {'water': 'Хөвсгөл нуур', 'state': 'Хөвсгөл аймаг'},
            },
            {'lat': 48.1, 'lon': 106.2, 'name': 'Хоосон'},
          ]);
        });

        final results = await Geocoding.search('  Хөвсгөл ');
        expect(seen.url.host, 'nominatim.openstreetmap.org');
        expect(seen.url.path, '/search');
        expect(seen.url.queryParameters['q'], 'Хөвсгөл');
        expect(seen.url.queryParameters['countrycodes'], 'mn');
        expect(seen.url.queryParameters['limit'], '5');
        expect(seen.url.queryParameters['format'], 'jsonv2');

        expect(results, hasLength(2));
        expect(results[0].latitude, closeTo(51.0204, 1e-9));
        expect(results[0].longitude, closeTo(100.4785, 1e-9));
        expect(results[0].name, 'Хөвсгөл нуур');
        expect(results[0].region, 'Хөвсгөл аймаг');
        expect(results[0].address, contains('Монгол'));
        // Numeric lat/lon and a bare `name` also parse.
        expect(results[1].latitude, 48.1);
        expect(results[1].name, 'Хоосон');
        expect(results[1].region, isNull);
      },
    );

    test('sends an identifying User-Agent on non-web platforms', () async {
      late http.Request seen;
      _use((req) async {
        seen = req;
        return _json([]);
      });
      await Geocoding.search('x');
      expect(seen.headers['User-Agent'], isNotNull);
      expect(seen.headers['User-Agent'], isNotEmpty);
    });

    test('an empty query never hits the network', () async {
      var calls = 0;
      _use((_) async {
        calls++;
        return _json([]);
      });
      expect(await Geocoding.search('   '), isEmpty);
      expect(calls, 0);
    });

    test(
      'identical queries (case/whitespace-insensitive) are cached',
      () async {
        var calls = 0;
        _use((_) async {
          calls++;
          return _json([
            {'lat': '1', 'lon': '2'},
          ]);
        });
        await Geocoding.search('Terelj');
        await Geocoding.search(' terelj ');
        expect(calls, 1);
        await Geocoding.search('Khuvsgul');
        expect(calls, 2);
      },
    );

    test('a non-list body yields no results', () async {
      _use((_) async => _json({'unexpected': true}));
      expect(await Geocoding.search('x'), isEmpty);
    });
  });

  group('reverse', () {
    test(
      'keeps the clicked coordinates, not the matched object centre',
      () async {
        late http.Request seen;
        _use((req) async {
          seen = req;
          return _json({
            'lat': '47.0',
            'lon': '107.0',
            'display_name': 'Тэрэлж, Төв аймаг',
            'address': {'village': 'Тэрэлж', 'province': 'Төв аймаг'},
          });
        });
        final place = await Geocoding.reverse(47.12345, 107.54321);
        expect(seen.url.path, '/reverse');
        expect(seen.url.queryParameters['lat'], '47.12345');
        expect(seen.url.queryParameters['lon'], '107.54321');
        expect(place.latitude, 47.12345);
        expect(place.longitude, 107.54321);
        expect(place.name, 'Тэрэлж');
        expect(place.region, 'Төв аймаг');
      },
    );

    test(
      'is cached per ~11 m cell but still reports the new click point',
      () async {
        var calls = 0;
        _use((_) async {
          calls++;
          return _json({'lat': '1', 'lon': '2', 'display_name': 'A'});
        });
        await Geocoding.reverse(47.12341, 107.54321);
        final again = await Geocoding.reverse(47.123412, 107.543212);
        expect(calls, 1);
        expect(again.latitude, 47.123412);
        await Geocoding.reverse(47.2, 107.5);
        expect(calls, 2);
      },
    );

    test('an {error: ...} body is reported as "address not found"', () async {
      _use((_) async => _json({'error': 'Unable to geocode'}));
      final e = await _failure(() => Geocoding.reverse(0, 0));
      expect(e.message, 'Энэ цэгийн хаяг олдсонгүй. Өөр цэг сонгоно уу.');
    });
  });

  group('errors', () {
    test('429 asks the user to wait', () async {
      _use((_) async => http.Response('', 429));
      final e = await _failure(() => Geocoding.search('x'));
      expect(
        e.message,
        'Хэт олон хүсэлт илгээлээ. Түр хүлээгээд дахин оролдоно уу.',
      );
    });

    test('403 says access was blocked', () async {
      _use((_) async => http.Response('', 403));
      final e = await _failure(() => Geocoding.search('x'));
      expect(e.message, 'Хайлтын үйлчилгээ хандалтыг хаасан байна.');
    });

    test('other status codes include the code', () async {
      _use((_) async => http.Response('', 503));
      final e = await _failure(() => Geocoding.search('x'));
      expect(e.message, 'Хайлт амжилтгүй боллоо (код 503).');
    });

    test('a transport failure is a network message', () async {
      _use((_) async => throw http.ClientException('offline'));
      final e = await _failure(() => Geocoding.search('x'));
      expect(e.message, 'Сүлжээнд холбогдож чадсангүй. Интернэтээ шалгана уу.');
    });

    test('invalid JSON is reported, not thrown raw', () async {
      _use((_) async => http.Response('<html>', 200));
      final e = await _failure(() => Geocoding.search('x'));
      expect(e.message, 'Серверийн хариуг уншиж чадсангүй.');
    });

    test('a failure does not poison later requests or get cached', () async {
      var calls = 0;
      _use((_) async {
        calls++;
        return calls == 1
            ? http.Response('', 429)
            : _json([
                {'lat': '1', 'lon': '2'},
              ]);
      });
      await _failure(() => Geocoding.search('x'));
      expect(await Geocoding.search('x'), hasLength(1));
      expect(calls, 2);
    });
  });

  test('requests are spaced by the configured gap', () async {
    final stamps = <DateTime>[];
    Geocoding.configureForTest(
      gap: const Duration(milliseconds: 120),
      client: MockClient((_) async {
        stamps.add(DateTime.now());
        return _json([]);
      }),
    );
    await Future.wait([Geocoding.search('a'), Geocoding.search('b')]);
    expect(stamps, hasLength(2));
    expect(
      stamps[1].difference(stamps[0]),
      greaterThanOrEqualTo(const Duration(milliseconds: 100)),
    );
  });
}
