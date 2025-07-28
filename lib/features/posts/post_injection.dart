import 'package:dadadu_app/config/app_config.dart'; // Assuming you have your keys/config here
import 'package:dadadu_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dadadu_app/features/posts/domain/usecases/upload_post_usecase.dart';
import 'package:dadadu_app/features/posts/presentation/bloc/diamond_bloc.dart';
import 'package:dadadu_app/features/posts/presentation/bloc/post_bloc.dart';
import 'package:get_it/get_it.dart';

import 'domain/usecases/send_unsend_diamond_usecase.dart';

// Use the same GetIt instance from your main injection container
final sl = GetIt.instance;

Future<void> postInjection() async {
  // ===================================================================
  // POSTS FEATURE
  // ===================================================================

  // --- Presentation Layer (BLoCs) ---
  sl.registerFactory(
    () => PostBloc(
        uploadPostUseCase: sl(), postRepository: sl(), profileRepository: sl()),
  );
  sl.registerFactory(
    () => DiamondBloc(sendDiamondUseCase: sl(), unsendDiamondUseCase: sl()),
  );

  // --- Domain Layer (Use Cases) ---
  sl.registerLazySingleton(() => UploadPostUseCase(sl()));
  sl.registerLazySingleton(() => SendDiamondUseCase(sl()));
  sl.registerLazySingleton(() => UnsendDiamondUseCase(sl()));

  // --- Data Layer (Repositories) ---
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Data Layer (Data Sources) ---
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(
      supabaseClient: sl(),
      // Assumes SupabaseClient is already registered globally
      minioClient: sl(),
      // Assumes Minio client is already registered globally
      uuid: sl(),
      // Assumes Uuid is already registered globally
      wasabiBucketName: AppConfig.wasabiBucketName,
      // Use a specific bucket for videos
      cdnHostname: AppConfig.bunnyCdnHostname,
    ),
  );
}
