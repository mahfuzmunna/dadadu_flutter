import 'package:dadadu_app/features/discover/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel(
      {required super.updatedAt,
      required super.latitude,
      required super.longitude,
      required super.location});

  Map<String, dynamic> toMap() {
    return {
      'updated_at'
          'latitude': latitude,
      'longitude': longitude,
      'location': location,
    };
  }
}
