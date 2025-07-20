import 'package:dartz/dartz.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Import for Stream type

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailPassword(String email, String password);
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword(
      String email, String password, String firstName, String lastName, String username);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  // Add this new method
  Stream<firebase_auth.User?> get authStateChanges; // Expose stream through repository
}