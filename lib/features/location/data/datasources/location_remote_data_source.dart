import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class LocationRemoteDataSource {
  Future<String> getLocationName(double latitude, double longitude);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final http.Client client;

  // IMPORTANT: Store your API key securely, not hardcoded.
  final String _apiKey = '9b46a2bb8cfb47b5af57ae70535e985f';

  LocationRemoteDataSourceImpl({required this.client});

  @override
  Future<String> getLocationName(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=$latitude+$longitude&key=$_apiKey&language=en&pretty=1');

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final components = data['results'][0]['components'];
        // Example: "Tangail, Dhaka Division" - customize as needed
        final city = components['city'] ?? components['state_district'] ?? '';
        final state = components['state'] ?? '';
        if (city.isNotEmpty && state.isNotEmpty) {
          return '$city, $state';
        }
        return city.isNotEmpty ? city : state;
      }
    }
    throw Exception('Failed to get location name');
  }
}
