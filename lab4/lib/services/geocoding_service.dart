import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/picked_location.dart';

/// A geocoding failure with a message that is safe to show to the user.
class GeocodingException implements Exception {
  const GeocodingException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thin client for OpenStreetMap's Nominatim. Its usage policy allows at most
/// one request per second, an identifying User-Agent, and asks clients to cache
/// results — all three are handled here.
class Geocoding {
  Geocoding._();

  static const _host = 'nominatim.openstreetmap.org';
  static const _minGap = Duration(milliseconds: 1100);

  static http.Client _client = http.Client();
  static Duration _gap = _minGap;
  static DateTime _lastRequest = DateTime.fromMillisecondsSinceEpoch(0);
  static Future<void> _queue = Future.value();

  static final _searchCache = <String, List<PickedLocation>>{};
  static final _reverseCache = <String, PickedLocation>{};

  /// Swaps the HTTP client and request spacing, and clears caches (tests).
  @visibleForTesting
  static void configureForTest({http.Client? client, Duration? gap}) {
    _client = client ?? http.Client();
    _gap = gap ?? _minGap;
    _lastRequest = DateTime.fromMillisecondsSinceEpoch(0);
    _queue = Future.value();
    _searchCache.clear();
    _reverseCache.clear();
  }

  /// Places matching [query], most relevant first (Mongolia only, up to 5).
  static Future<List<PickedLocation>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final key = q.toLowerCase();
    final cached = _searchCache[key];
    if (cached != null) return cached;

    final body = await _get('/search', {
      'q': q,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '5',
      'countrycodes': 'mn',
      'accept-language': 'mn',
    });
    final list = body is List ? body : const [];
    // Rows without usable coordinates are skipped rather than failing the search.
    final results = [
      for (final item in list.whereType<Map<String, dynamic>>()) ?_parse(item),
    ];
    return _searchCache[key] = results;
  }

  /// The address of a clicked point. The result keeps the clicked coordinates
  /// rather than the centre of the matched object.
  static Future<PickedLocation> reverse(double lat, double lng) async {
    final key = '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}';
    final cached = _reverseCache[key];
    if (cached != null) return _at(cached, lat, lng);

    final body = await _get('/reverse', {
      'lat': '$lat',
      'lon': '$lng',
      'format': 'jsonv2',
      'addressdetails': '1',
      'zoom': '14',
      'accept-language': 'mn',
    });
    if (body is! Map<String, dynamic> || body['error'] != null) {
      throw const GeocodingException(
        'Энэ цэгийн хаяг олдсонгүй. Өөр цэг сонгоно уу.',
      );
    }
    final parsed = _parse(body);
    if (parsed == null) {
      throw const GeocodingException('Серверийн хариуг уншиж чадсангүй.');
    }
    return _reverseCache[key] = _at(parsed, lat, lng);
  }

  static PickedLocation _at(PickedLocation p, double lat, double lng) =>
      PickedLocation(
        latitude: lat,
        longitude: lng,
        address: p.address,
        name: p.name,
        region: p.region,
      );

  /// Runs requests one at a time, [_gap] apart.
  static Future<dynamic> _get(String path, Map<String, String> params) {
    final result = _queue.then((_) => _send(path, params));
    // Keep the queue alive after a failure.
    _queue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  static Future<dynamic> _send(String path, Map<String, String> params) async {
    final wait = _lastRequest.add(_gap).difference(DateTime.now());
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    _lastRequest = DateTime.now();

    final uri = Uri.https(_host, path, params);
    final http.Response response;
    try {
      response = await _client
          .get(
            uri,
            // Browsers forbid setting User-Agent; they send their own.
            headers: {if (!kIsWeb) 'User-Agent': nominatimUserAgent},
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const GeocodingException(
        'Хариу удаан байна. Холболтоо шалгаад дахин оролдоно уу.',
      );
    } catch (_) {
      throw const GeocodingException(
        'Сүлжээнд холбогдож чадсангүй. Интернэтээ шалгана уу.',
      );
    }

    switch (response.statusCode) {
      case 200:
        try {
          return jsonDecode(utf8.decode(response.bodyBytes));
        } on FormatException {
          throw const GeocodingException('Серверийн хариуг уншиж чадсангүй.');
        }
      case 429:
        throw const GeocodingException(
          'Хэт олон хүсэлт илгээлээ. Түр хүлээгээд дахин оролдоно уу.',
        );
      case 403:
        throw const GeocodingException(
          'Хайлтын үйлчилгээ хандалтыг хаасан байна.',
        );
      default:
        throw GeocodingException(
          'Хайлт амжилтгүй боллоо (код ${response.statusCode}).',
        );
    }
  }

  static const _nameKeys = [
    'tourism',
    'natural',
    'water',
    'leisure',
    'historic',
    'village',
    'town',
    'hamlet',
    'city',
    'county',
  ];
  static const _regionKeys = ['state', 'city', 'province', 'region', 'county'];

  /// Nominatim's jsonv2 sends lat/lon as strings; null when they are unusable.
  static PickedLocation? _parse(Map<String, dynamic> r) {
    final lat = double.tryParse('${r['lat']}');
    final lng = double.tryParse('${r['lon']}');
    if (lat == null || lng == null || !lat.isFinite || !lng.isFinite) {
      return null;
    }
    final address = r['address'];
    String? pick(List<String> keys) {
      if (address is! Map) return null;
      for (final key in keys) {
        final value = address[key];
        if (value is String && value.isNotEmpty) return value;
      }
      return null;
    }

    final display = r['display_name'];
    final title = r['name'];
    return PickedLocation(
      latitude: lat,
      longitude: lng,
      address: display is String ? display : null,
      name:
          pick(_nameKeys) ??
          (title is String && title.isNotEmpty ? title : null),
      region: pick(_regionKeys),
    );
  }
}
