// lib/features/profile/profile_injection.dart

import 'package:get_it/get_it.dart';

// Profile Feature Data Layer
import 'data/datasources/profile_remote_data_source.dart';
import 'data/repositories/profile_repository_impl.dart';
// Profile Feature Domain Layer
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/delete_profile_image_usecase.dart';
import 'domain/usecases/get_posts_usecase.dart'; // Ensure this is imported
import 'domain/usecases/get_user_profile_usecase.dart';
import 'domain/usecases/update_profile_usecase.dart';
import 'domain/usecases/upload_profile_image_usecase.dart';
// Profile Feature Presentation Layer
import 'presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance; // Re-use the global GetIt instance

Future<void> profileInjection() async {
  // Profile Feature - Presentation Layer (Bloc)
  sl.registerFactory(() => ProfileBloc(
        getUserProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        getPostsUseCase: sl(),
        getCurrentUserUseCase: sl(),
        // From Auth feature
        uploadProfileImageUseCase: sl(),
        deleteProfileImageUseCase: sl(),
      ));

  // Profile Feature - Domain Layer (Use Cases)
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfileImageUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProfileImageUseCase(sl()));

  // Profile Feature - Data Layer (Repository)
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Profile Feature - Data Layer (Data Sources)
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firestore: sl(),
      firebaseStorage: sl(),
      uuid: sl(),
    ),
  );
}