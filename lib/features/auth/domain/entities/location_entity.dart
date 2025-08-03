import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  const LocationEntity({
    this.latitude,
    this.longitude,
    this.locationName,
  });

  @override
  List<Object?> get props => [latitude, longitude, locationName];

  factory LocationEntity.fromMap(Map<String, dynamic> map) {
    return LocationEntity(
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      locationName: map['location_name'] as String?,
    );
  }
}
