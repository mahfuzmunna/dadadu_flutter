class ServerException implements Exception {
  final String message;
  final String code;

  ServerException(this.message, {required this.code});
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