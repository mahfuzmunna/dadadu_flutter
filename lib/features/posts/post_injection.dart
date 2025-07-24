import 'package:dadadu_app/config/app_config.dart'; // Assuming you have your keys/config here
import 'package:dadadu_app/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:dadadu_app/features/posts/domain/repositories/post_repository.dart';
import 'package:dadadu_app/features/posts/domain/usecases/upload_post_usecase.dart';
import 'package:dadadu_app/features/posts/presentation/bloc/upload_bloc.dart';
import 'package:get_it/get_it.dart';

// Use the same GetIt instance from your main injection container
final sl = GetIt.instance;

Future<void> postInjection() async {
  // ===================================================================
  // POSTS FEATURE
  // ===================================================================

  // --- Presentation Layer (BLoCs) ---
  sl.registerFactory(
    () => UploadBloc(uploadPostUseCase: sl()),
  );

  // --- Domain Layer (Use Cases) ---
  sl.registerLazySingleton(() => UploadPostUseCase(sl()));

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
