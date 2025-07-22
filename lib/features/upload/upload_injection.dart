import 'package:dadadu_app/features/upload/presentation/bloc/upload_bloc.dart';

import '../../config/app_config.dart';
import '../../injection_container.dart';
import 'data/datasources/post_remote_data_source.dart';
import 'data/datasources/post_remote_data_source_impl.dart';
import 'data/repositories/post_repository_impl.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/usecases/upload_post_usecase.dart';

Future<void> uploadInjection() async {
  //! Features - Auth
  // ... (Auth bloc, use cases, repository, data sources unchanged) ...

  //! Features - Upload
  // Bloc
  sl.registerFactory(
    () => UploadBloc(
      uploadPostUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => UploadPostUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(
      sl(), // SupabaseClient instance
      // Provide your Wasabi and BunnyCDN details here
      wasabiAccessKey: AppConfig.wasabiAccessKey,
      wasabiSecretKey: AppConfig.wasabiSecretKey,
      wasabiEndpoint: AppConfig.wasabiEndpoint,
      // Changed to endpoint
      wasabiBucketName: AppConfig.wasabiBucketName,
      bunnyCdnHostname: AppConfig.bunnyCdnHostname,
    ),
  );

  //! External
  // sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}