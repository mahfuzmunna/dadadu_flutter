import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore if used

import 'features/auth/auth_injection.dart'; // Import feature-specific injection files
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_feed_posts_usecase.dart';
import 'features/home/home_injection.dart';
import 'features/discover/discover_injection.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/upload/upload_injection.dart';
import 'features/friends/friends_injection.dart';
import 'features/profile/profile_injection.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External Dependencies
  sl.registerLazySingleton(() => firebase_auth.FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance); // If using Firestore

  // Feature-specific injections
  await authInjection();
  await homeInjection();
  await discoverInjection();
  await uploadInjection();
  await friendsInjection();
  await profileInjection();
}

// Function to call Auth feature's injection setup
Future<void> authInjection() async {
  // Bloc
  sl.registerFactory(() => AuthBloc(
    signInUseCase: sl(),
    signUpUseCase: sl(),
    authRepository: sl(), // AuthBloc now takes AuthRepository to listen to authStateChanges
  ));

  // Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  // sl.registerLazySingleton(() => SignOutUseCase(sl()));
  // sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  // sl.registerLazySingleton(() => SendPasswordResetEmailUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data Sources
  // LINE 68 IS LIKELY HERE: Ensure both sl() calls are present
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => FirebaseAuthRemoteDataSourceImpl(
      sl<firebase_auth.FirebaseAuth>(), // First positional argument
      sl<FirebaseFirestore>(),       // Second positional argument
    ),
  );
}

// Example for Home feature injection
Future<void> homeInjection() async {
  // BLoC
  sl.registerFactory(() => HomeBloc(getFeedPostsUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetFeedPostsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());

  // Data sources (if any specific to home, e.g., local cache)
  // sl.registerLazySingleton<HomeLocalDataSource>(() => HomeLocalDataSourceImpl());
}

// Add similar injection functions for other features
Future<void> discoverInjection() async {
  // sl.registerFactory(() => DiscoverBloc(...));
  // sl.registerLazySingleton(() => DiscoverRepository(...));
}
Future<void> uploadInjection() async {
  // sl.registerFactory(() => UploadBloc(...));
}
Future<void> friendsInjection() async {
  // sl.registerFactory(() => FriendsBloc(...));
}
Future<void> profileInjection() async {
  // BLoC
  sl.registerFactory(
        () => ProfileBloc(
      getUserProfileUseCase: sl(),
      updateProfileUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSourceImpl(sl(), sl()), // Pass Firestore and FirebaseAuth
  );
}