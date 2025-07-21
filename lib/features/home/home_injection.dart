// lib/features/home/home_injection.dart

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dadadu_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:dadadu_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:dadadu_app/features/home/domain/repositories/home_repository.dart';
import 'package:dadadu_app/features/home/domain/usecases/get_posts_usecase.dart';
import 'package:dadadu_app/features/home/domain/usecases/get_user_info_usecase.dart';
import 'package:dadadu_app/features/home/presentation/bloc/home_feed_bloc.dart';

Future<void> homeInjection() async {
  final sl = GetIt.instance;

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
        () => HomeRemoteDataSourceImpl(firestore: sl()),
  );
}