import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/services/auth_service.dart';

class AuthRemoteDataSource {
  final AuthService authService;

  AuthRemoteDataSource(this.authService);

  Future<User> login(String email, String password) {
    return authService.signInWithEmail(email, password);
  }
}
