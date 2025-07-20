import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getUserProfile(String uid);
  Future<Either<Failure, void>> updateProfile(UserEntity user);
// Add other methods like updateProfilePhoto, updateUserModeEmoji, etc.
}