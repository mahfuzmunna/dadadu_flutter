import 'package:dadadu_app/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:dadadu_app/features/posts/domain/usecases/get_post_comments_usecase.dart';

import '../../injection_container.dart';

Future<void> commentsInjection() async {
  sl.registerFactory(
    () => CommentsBloc(getPostCommentsUseCase: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPostCommentsUseCase(sl()));
}
