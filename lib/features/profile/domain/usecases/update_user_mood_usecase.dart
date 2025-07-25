import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class UpdateUserMoodUseCase implements UseCase<void, UpdateUserMoodParams> {
  final ProfileRepository repository;

  UpdateUserMoodUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserMoodParams params) async {
    return await repository.updateUserMood(params);
  }
}

class UpdateUserMoodParams extends Equatable {
  final String userId;
  final String moodStatus;

  const UpdateUserMoodParams({required this.userId, required this.moodStatus});

  @override
  List<Object> get props => [userId, moodStatus];
}
