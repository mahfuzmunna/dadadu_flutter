import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String updatedAt;
  final double latitude;
  final double longitude;
  final String location;

  const LocationEntity(
      {required this.updatedAt,
      required this.latitude,
      required this.longitude,
      required this.location});

  @override
  List<Object?> get props => [updatedAt, latitude, longitude, location];
}
