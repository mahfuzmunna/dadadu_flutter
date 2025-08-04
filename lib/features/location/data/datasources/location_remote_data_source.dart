import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Reverse geocoding failure with context.
class GeocodingException implements Exception {
  final String message;

  GeocodingException(this.message);

  @override
  String toString() => 'GeocodingException: $message';
}

abstract class LocationRemoteDataSource {
  Future<String> getLocationName(double latitude, double longitude);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final http.Client client;

  // IMPORTANT: Don't hardcode in production. Inject via secure config/env.
  final String _apiKey = '9b46a2bb8cfb47b5af57ae70535e985f';

  LocationRemoteDataSourceImpl({required this.client});

  /// Returns a human-readable location like "Dhaka, Dhaka Division"
  @override
  Future<String> getLocationName(double latitude, double longitude) async {
    final uri = Uri.https(
      'api.opencagedata.com',
      '/geocode/v1/json',
      {
        'q': '$latitude,$longitude',
        'key': _apiKey,
        'language': 'en',
        'pretty': '0',
        'no_annotations': '1',
      },
    );

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw GeocodingException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }

    final dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (e) {
      throw GeocodingException('Failed to decode response JSON: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw GeocodingException('Unexpected response shape: not a map');
    }

    final Map<String, dynamic> data = decoded;

    final results = data['results'];
    if (results is! List || results.isEmpty) {
      throw GeocodingException('No results from geocoding API');
    }

    final first = results.first;
    if (first is! Map<String, dynamic>) {
      throw GeocodingException('Unexpected result entry shape');
    }

    final componentsRaw = first['components'];
    if (componentsRaw is! Map<String, dynamic>) {
      throw GeocodingException('Missing or invalid components in response');
    }
    final Map<String, dynamic> components = componentsRaw;

    // Helper to pick the first non-empty string from given keys.
    String? pickFirst(Map<String, dynamic> m, List<String> keys) {
      for (final key in keys) {
        final val = m[key];
        if (val is String && val
            .trim()
            .isNotEmpty) {
          return val.trim();
        }
      }
      return null;
    }

    final locality = pickFirst(components, [
      'city',
      'town',
      'village',
      'municipality',
      'state_district',
    ]);
    final region = pickFirst(components, ['state']);
    final country = pickFirst(components, ['country']);

    // Build best readable string.
    if (locality != null && region != null) {
      return '$locality, $region';
    } else if (locality != null) {
      return locality;
    } else if (region != null) {
      return region;
    } else if (country != null) {
      return country;
    } else {
      throw GeocodingException('Could not derive a readable location');
    }
  }
}
