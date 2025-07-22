class ServerException implements Exception {
  final String message;
  final String code;
  final dynamic details;
  final dynamic hint;

  ServerException(
    this.message, {
    this.code = 'SERVER_ERROR',
    this.details = 'DETAILS',
    this.hint = 'HINT',
  });
}

// lib/core/errors/exceptions.dart

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'A cache error occurred.'});
}

class AuthException implements Exception {
  // Add this if not present
  final String message;

  const AuthException({this.message = 'An authentication error occurred.'});
}