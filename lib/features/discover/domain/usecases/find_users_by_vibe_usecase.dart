import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dadadu_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// A new model to hold both the user and their calculated distance
class UserWithDistance extends Equatable {
  final UserEntity user;
  final double distanceInKm;

  const UserWithDistance({required this.user, required this.distanceInKm});

  @override
  List<Object> get props => [user, distanceInKm];
}

class FindUsersByVibeUseCase
    implements UseCase<List<UserWithDistance>, FindUsersByVibeParams> {
  final ProfileRepository repository;

  FindUsersByVibeUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserWithDistance>>> call(
      FindUsersByVibeParams params) async {
    return await repository.findUsersByVibe(params);
  }
}

class FindUsersByVibeParams extends Equatable {
  final String vibe;
  final double currentLatitude;
  final double currentLongitude;
  final double maxDistanceInKm;

  const FindUsersByVibeParams({
    required this.vibe,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.maxDistanceInKm,
  });

  @override
  List<Object> get props =>
      [vibe, currentLatitude, currentLongitude, maxDistanceInKm];
}