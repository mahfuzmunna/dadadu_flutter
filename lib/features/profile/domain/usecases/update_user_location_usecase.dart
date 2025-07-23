// lib/features/profile/domain/usecases/update_user_location_usecase.dart
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateUserLocationUseCase
    implements UseCase<void, UpdateUserLocationParams> {
  final ProfileRepository repository;

  UpdateUserLocationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserLocationParams params) async {
    return await repository.updateUserLocation(params);
  }
}

class UpdateUserLocationParams extends Equatable {
  final String userId;
  final double latitude;
  final double longitude;
  final String locationName;

  const UpdateUserLocationParams({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  List<Object> get props => [userId, latitude, longitude, locationName];
}
