import 'package:dadadu_app/features/chat/chat_injection.dart';
import 'package:dadadu_app/features/comments/comments_injection.dart';
import 'package:dadadu_app/features/discover/discover_injection.dart';
import 'package:get_it/get_it.dart';
import 'package:minio/minio.dart';
import 'package:uuid/uuid.dart';

import 'config/app_config.dart';
import 'features/auth/auth_injection.dart'; // Import feature-specific injection files
// import 'features/now/domain/usecases/get_feed_posts_usecase.dart';
import 'features/now/now_injection.dart';
import 'features/posts/post_injection.dart';
import 'features/profile/profile_injection.dart';
import 'features/upload/upload_injection.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External Dependencies
  sl.registerLazySingleton(() => const Uuid()); // NEW: Register UUID generator
  sl.registerLazySingleton(() => Minio(
        endPoint: AppConfig.wasabiEndpoint,
        // Or your specific Wasabi endpoint, e.g., 's3.us-east-1.wasabisys.com'
        accessKey: AppConfig.wasabiAccessKey,
        // ⚠️ Replace with your Wasabi Access Key
        secretKey: AppConfig.wasabiSecretKey,
        // ⚠️ Replace with your Wasabi Secret Key
        useSSL: true,
      ));

  // Feature-specific injections
  await authInjection();
  await nowInjection();
  await postInjection();
  await commentsInjection();
  await discoverInjection();
  await uploadInjection();
  await chatInjection();
  await profileInjection();
}

// Function to call Auth feature's injection setup


// Example for Home feature injection
// Future<void> homeInjection() async {
//   // BLoC
//   sl.registerFactory(() => HomeBloc(getFeedPostsUseCase: sl()));
//
//   // Use cases
//   sl.registerLazySingleton(() => GetFeedPostsUseCase(sl()));
//
//   // Repository
//   sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
//
//   // Data sources (if any specific to home, e.g., local cache)
//   // sl.registerLazySingleton<HomeLocalDataSource>(() => HomeLocalDataSourceImpl());
// }

// Add similar injection functions for other features

/*Future<void> uploadInjection() async {
  // Bloc
  sl.registerFactory(
        () => UploadPostBloc(
      uploadVideoToStorageUseCase: sl(),
      createPostInFirestoreUseCase: sl(),
      updateUserUploadedVideosUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => UploadVideoToStorageUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostInFirestoreUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUploadedVideosUseCase(sl()));

  // Repository
  sl.registerLazySingleton<UploadPostRepository>(
        () => UploadPostRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<UploadPostRemoteDataSource>(
        () => UploadPostRemoteDataSourceImpl(sl(), sl()), // Pass FirebaseStorage and FirebaseFirestore
  );
}*/