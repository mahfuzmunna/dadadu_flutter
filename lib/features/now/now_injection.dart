// lib/features/now/now_injection.dart

import 'package:dadadu_app/features/now/data/datasources/feed_remote_data_source.dart';
import 'package:dadadu_app/features/now/domain/repositories/feed_repository.dart';
import 'package:dadadu_app/features/now/presentation/bloc/feed_bloc.dart';
import 'package:dadadu_app/features/posts/domain/usecases/stream_feed_usecase.dart';
import 'package:get_it/get_it.dart';


// No need to redeclare 'final sl = GetIt.instance;' if it's already global via injection_container.dart
// You can use the existing 'sl' if it's imported correctly.
// For consistency with other injection files, I'll keep it as you had it.
final sl = GetIt.instance;

Future<void> nowInjection() async {
  // Bloc
  sl.registerFactory(
    () => FeedBloc(repository: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => StreamFeedUseCase(sl()));
  // sl.registerLazySingleton(() => StreamAllPostsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(sl()),
  );

  // sl.registerLazySingleton<PostRepository>(
  //       () => PostRepositoryImpl(remoteDataSource: sl()),
  // );

  // Data sources
  // sl.registerLazySingleton<PostRemoteDataSource>(
  //     () => PostRemoteDataSourceImpl(sl(),
  //         wasabiAccessKey: AppConfig.wasabiAccessKey,
  //         wasabiSecretKey: AppConfig.wasabiSecretKey,
  //         wasabiEndpoint: AppConfig.wasabiEndpoint,
  //         wasabiBucketName: AppConfig.wasabiBucketName,
  //         bunnyCdnHostname: AppConfig.bunnyCdnHostname),
  // );
  sl.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(sl()),
  );
}
