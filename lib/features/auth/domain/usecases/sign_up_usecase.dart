import 'package:dartz/dartz.dart';
import '../../domain/usecases/params.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<UserEntity, Params> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(Params params) async {
    return await repository.signUpWithEmailPassword(
        params.email, params.password);
  }
}

// Params class is the same as SignInUseCase, can be reused or kept separate
// for clarity if sign-up parameters differ in the future.
// For now, let's just use the same Params.
// import 'package:equatable/equatable.dart';
