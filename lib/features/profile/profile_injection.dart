// lib/features/profile/profile_injection.dart

import 'package:dadadu_app/features/location/data/datasources/location_remote_data_source.dart';
import 'package:dadadu_app/features/location/domain/repositories/location_repository.dart';
import 'package:dadadu_app/features/location/domain/usecases/get_location_name_usecase.dart';
import 'package:dadadu_app/features/profile/presentation/bloc/follow_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart'; // Import your AppConfig
// Profile Feature Data Layer
import '../location/data/repositories/location_repository_impl.dart';
import 'data/datasources/profile_remote_data_source.dart';
// Profile Feature Domain Layer
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/delete_profile_image_usecase.dart';
import 'domain/usecases/follow_unfollow_user_usecase.dart';
import 'domain/usecases/get_posts_usecase.dart';
import 'domain/usecases/get_user_profile_data_usecase.dart';
import 'domain/usecases/stream_user_profile_usecase.dart';
import 'domain/usecases/update_profile_photo_usecase.dart';
// Profile Feature Presentation Layer
import 'domain/usecases/update_user_location_usecase.dart';
import 'domain/usecases/update_user_mood_usecase.dart';
import 'domain/usecases/update_user_profile_usecase.dart';
import 'presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance; // Re-use the global GetIt instance

Future<void> profileInjection() async {
  // Profile Feature - Presentation Layer (Bloc)
  sl.registerFactory(() => ProfileBloc(
        getUserProfileUseCase: sl(),
        updateUserProfileUseCase: sl(),
        getPostsUseCase: sl(),
        getCurrentUserUseCase: sl(),
        // From Auth feature, ensure it's registered
        updateProfilePhotoUseCase: sl(),
        deleteProfileImageUseCase: sl(),
        updateUserLocationUseCase: sl(),
        updateUserMoodUseCase: sl(),
        updateDiscoverModeUseCase: sl(),
        streamUserProfileUseCase: sl(),
      ));
  sl.registerFactory(
      () => FollowBloc(followUserUseCase: sl(), unfollowUserUseCase: sl()));

  // Profile Feature - Domain Layer (Use Cases)
  sl.registerLazySingleton(() => GetUserProfileDataUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePhotoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProfileImageUseCase(sl()));
  sl.registerLazySingleton(() => GetLocationNameUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserLocationUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserMoodUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDiscoverModeUseCase(sl()));
  sl.registerLazySingleton(() => StreamUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => FollowUserUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowUserUseCase(sl()));

  sl.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(remoteDataSource: sl()));
  // Profile Feature - Data Layer (Repository)

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Profile Feature - Data Layer (Data Sources)
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      supabaseClient: sl(),
      minioClient: sl(),
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
  sl.registerLazySingleton<LocationRemoteDataSource>(
      () => LocationRemoteDataSourceImpl(client: sl()));

  // Ensure these external dependencies are registered once, typically in main injection
  // If you register them elsewhere globally, you can remove these lines
  // sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  // sl.registerLazySingleton<Uuid>(() => Uuid());
  sl.registerLazySingleton(() => http.Client());
}