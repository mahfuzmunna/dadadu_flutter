// lib/features/home/home_injection.dart

import 'package:dadadu_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:dadadu_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:dadadu_app/features/home/domain/repositories/home_repository.dart';
import 'package:dadadu_app/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:dadadu_app/features/home/domain/usecases/get_user_info_usecase.dart';
import 'package:dadadu_app/features/home/presentation/bloc/home_feed_bloc.dart';
import 'package:get_it/get_it.dart';

// No need to redeclare 'final sl = GetIt.instance;' if it's already global via injection_container.dart
// You can use the existing 'sl' if it's imported correctly.
// For consistency with other injection files, I'll keep it as you had it.
final sl = GetIt.instance;

Future<void> homeInjection() async {
  // Bloc
  sl.registerFactory(
        () => HomeFeedBloc(
      getPostsUseCase: sl(),
      getUserInfoUseCase: sl(),
    ),
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