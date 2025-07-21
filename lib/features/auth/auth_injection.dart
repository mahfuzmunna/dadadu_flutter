// lib/features/auth/auth_injection.dart

import 'package:get_it/get_it.dart';

// Auth Data
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
// Auth Domain
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/send_password_reset_email_usecase.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'domain/usecases/sign_out_usecase.dart';
import 'domain/usecases/sign_up_usecase.dart';
// Auth Presentation
import 'presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance; // Re-use the same GetIt instance

Future<void> authInjection() async {
  // Bloc
  sl.registerFactory(() => AuthBloc(
        authRepository: sl(),
        getCurrentUserUseCase: sl(),
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        sendPasswordResetEmailUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmailUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSourceImpl(
      sl(), // Get the FirebaseAuth instance from global sl
      sl(), // Get the FirebaseFirestore instance from global sl
    ),
  );
}