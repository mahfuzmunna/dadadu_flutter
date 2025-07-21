import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  // Removed 'const' from the constructor of the abstract class.
  // This allows subclasses to pass non-constant values to 'properties'.
  const Failure([this.properties = const <dynamic>[]]);

  final List<dynamic> properties;

  @override
  List<Object?> get props => properties;
}

class ServerFailure extends Failure {
  final String message;
  // Removed 'const' from the constructor here.
  // Now, 'message' can be a runtime value, and it can be passed to super.
  ServerFailure({required this.message}) : super([message]);
}

class CacheFailure extends Failure {
  final String message;

  // Removed 'const' from the constructor here.
  // Now, 'message' can be a runtime value, and it can be passed to super.
  CacheFailure({required this.message}) : super([message]);
}

// Specific Authentication Failures
class InvalidCredentialsFailure extends ServerFailure {
  InvalidCredentialsFailure({required String message}) : super(message: message);
}

class WeakPasswordFailure extends ServerFailure {
  WeakPasswordFailure({required String message}) : super(message: message);
}

class EmailAlreadyInUseFailure extends ServerFailure {
  EmailAlreadyInUseFailure({required String message}) : super(message: message);
}

class UserNotFoundFailure extends ServerFailure {
  UserNotFoundFailure({required String message}) : super(message: message);
}

class WrongPasswordFailure extends ServerFailure {
  WrongPasswordFailure({required String message}) : super(message: message);
}

class UnknownAuthFailure extends ServerFailure {
  UnknownAuthFailure({required String message}) : super(message: message);
}
// NEW: Storage specific failure
class StorageFailure extends ServerFailure {
  StorageFailure({required super.message});
}

class AuthFailure extends Failure {
  final String message;

  // Removed 'const' from the constructor here.
  // Now, 'message' can be a runtime value, and it can be passed to super.
  AuthFailure({required this.message}) : super([message]);
}