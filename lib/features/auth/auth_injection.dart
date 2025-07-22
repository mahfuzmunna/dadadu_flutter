import 'package:dadadu_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../injection_container.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/auth_remote_data_source_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/reset_password_usecase.dart';
import 'domain/usecases/sign_in_usecase.dart';
import 'domain/usecases/sign_in_with_oauth_usecase.dart';
import 'domain/usecases/sign_out_usecase.dart';
import 'domain/usecases/sign_up_usecase.dart';

Future<void> authInjection() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signInWithOAuthUseCase: sl(),
      signOutUseCase: sl(),
      resetPasswordUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithOAuthUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  //! External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}