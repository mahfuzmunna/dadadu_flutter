// lib/features/home/home_injection.dart

import 'package:dadadu_app/config/app_config.dart';
import 'package:dadadu_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:dadadu_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:dadadu_app/features/home/domain/repositories/home_repository.dart';
import 'package:dadadu_app/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:dadadu_app/features/home/domain/usecases/get_user_info_usecase.dart';
import 'package:dadadu_app/features/home/presentation/bloc/post_bloc.dart';
import 'package:get_it/get_it.dart';

import '../upload/data/datasources/post_remote_data_source.dart';
import '../upload/data/datasources/post_remote_data_source_impl.dart';
import '../upload/data/repositories/post_repository_impl.dart';
import '../upload/domain/repositories/post_repository.dart';

// No need to redeclare 'final sl = GetIt.instance;' if it's already global via injection_container.dart
// You can use the existing 'sl' if it's imported correctly.
// For consistency with other injection files, I'll keep it as you had it.
final sl = GetIt.instance;

Future<void> homeInjection() async {
  // Bloc
  sl.registerFactory(
    () => PostBloc(postRepository: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserInfoUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      // Changed from 'firestore' to 'supabaseClient'
      supabaseClient: sl(),
    ),
  );
}

Future<void> postInjection() async {
  // Register new Post related dependencies
  sl.registerFactory(() => PostBloc(postRepository: sl()));

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(sl(),
        wasabiAccessKey: AppConfig.wasabiAccessKey,
        wasabiSecretKey: AppConfig.wasabiSecretKey,
        wasabiEndpoint: AppConfig.wasabiEndpoint,
        wasabiBucketName: AppConfig.wasabiBucketName,
        bunnyCdnHostname: AppConfig.bunnyCdnHostname),
  );
  // ... rest of your existing injection setup
}