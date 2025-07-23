// lib/features/profile/profile_injection.dart

import 'package:get_it/get_it.dart';

import '../../config/app_config.dart'; // Import your AppConfig
// Profile Feature Data Layer
import 'data/datasources/profile_remote_data_source.dart';
import 'data/datasources/profile_remote_data_source_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
// Profile Feature Domain Layer
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/delete_profile_image_usecase.dart';
import 'domain/usecases/get_posts_usecase.dart';
import 'domain/usecases/get_user_profile_usecase.dart';
import 'domain/usecases/update_profile_photo_usecase.dart';
import 'domain/usecases/update_profile_usecase.dart';
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
        // From Auth feature, ensure it's registered
        uploadProfileImageUseCase: sl(),
        deleteProfileImageUseCase: sl(),
      ));

  // Profile Feature - Domain Layer (Use Cases)
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePhotoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProfileImageUseCase(sl()));

  // Profile Feature - Data Layer (Repository)
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Profile Feature - Data Layer (Data Sources)
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      supabaseClient: sl(),
      // Inject SupabaseClient
      uuid: sl(),
      // Inject Uuid
      // NEW: Wasabi/BunnyCDN details for profile image storage
      wasabiAccessKey: AppConfig.wasabiAccessKey,
      wasabiSecretKey: AppConfig.wasabiSecretKey,
      wasabiEndpoint: AppConfig.wasabiEndpoint,
      wasabiBucketName: AppConfig.wasabiBucketName,
      // Use a specific bucket for profile images
      bunnyCdnHostname: AppConfig
          .bunnyCdnHostname, // Or a specific one if profile images use a different CDN hostname
    ),
  );

  // Ensure these external dependencies are registered once, typically in main injection
  // If you register them elsewhere globally, you can remove these lines
  // sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  // sl.registerLazySingleton<Uuid>(() => Uuid());
}