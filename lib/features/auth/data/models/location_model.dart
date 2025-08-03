import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    super.latitude,
    super.longitude,
    super.locationName,
  });

  factory LocationModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const LocationModel();
    }
    return LocationModel(
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationName: map['locationName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }
}
