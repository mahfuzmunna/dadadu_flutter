import 'package:dadadu_app/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:get_it/get_it.dart';

import 'domain/usecases/find_users_by_vibe_usecase.dart';

final sl = GetIt.instance; // Re-use the global GetIt instance

Future<void> discoverInjection() async {
  // BLoCs
  sl.registerFactory(() => DiscoverBloc(findUsersByVibeUseCase: sl()));

  // Use Cases
  sl.registerLazySingleton(() => FindUsersByVibeUseCase(sl()));
}
