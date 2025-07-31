// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Add new parameters to the signUp method
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    String? fullName, // NEW
    String? username, // NEW
    String? referralId, // NEW
  });

  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> signInWithOAuth({
    required OAuthProvider provider,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Stream<UserEntity?> onAuthStateChange();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    String? fullName, // NEW
    String? username, // NEWW
    String? referralId, // NEW
  }) async {
    try {
      // Pass all signup data to the remote data source
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
        referralId: referralId,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
          email: email, password: password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithOAuth({
    required OAuthProvider provider,
  }) async {
    try {
      await remoteDataSource.signInWithOAuth(provider: provider);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
  }) async {
    try {
      await remoteDataSource.resetPassword(email: email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Stream<UserEntity?> onAuthStateChange() {
    return remoteDataSource.onAuthStateChange().map((userModel) => userModel);
  }
}