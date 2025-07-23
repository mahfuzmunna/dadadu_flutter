import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

import '../repositories/profile_repository.dart';

class StreamUserProfileUseCase implements UseCase<Stream<UserEntity>, String> {
  final ProfileRepository repository;

  StreamUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<UserEntity>>> call(String params) async {
    return repository.streamUserProfile(params);
  }
}
