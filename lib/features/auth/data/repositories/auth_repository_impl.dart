import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailPassword(
      String email, String password) async {
    try {
      final userModel =
      await remoteDataSource.signInWithEmailPassword(email, password);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(_handleFirebaseAuthException(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword(
      String email, String password) async {
    try {
      final userModel =
      await remoteDataSource.signUpWithEmailPassword(email, password);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(_handleFirebaseAuthException(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(_handleFirebaseAuthException(e.message));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  UserEntity? get currentUser {
    final firebaseUser = remoteDataSource.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  Failure _handleFirebaseAuthException(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return UserNotFoundFailure(
            message: 'No user found for that email.');
      case 'wrong-password':
        return WrongPasswordFailure(
            message: 'Wrong password provided for that user.');
      case 'email-already-in-use':
        return EmailAlreadyInUseFailure(
            message: 'The email address is already in use by another account.');
      case 'weak-password':
        return WeakPasswordFailure(
            message: 'The password provided is too weak.');
      case 'invalid-email':
        return InvalidCredentialsFailure(
            message: 'The email address is not valid.');
      default:
        return UnknownAuthFailure(
            message: 'An unknown authentication error occurred: $errorCode');
    }
  }
}