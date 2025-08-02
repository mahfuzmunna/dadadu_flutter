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
}
