import 'package:dadadu_app/features/comments/presentation/bloc/comments_bloc.dart';
import 'package:dadadu_app/features/comments/presentation/bloc/like_unlike_comment_bloc.dart';
import 'package:dadadu_app/features/posts/domain/usecases/get_post_comments_usecase.dart';

import '../../injection_container.dart';
import 'domain/usecases/like_unlike_comment_usecase.dart';

Future<void> commentsInjection() async {
  sl.registerFactory(
    () => CommentsBloc(getPostCommentsUseCase: sl(), addCommentUseCase: sl()),
  );
  sl.registerFactory(
    () => LikeUnlikeCommentBloc(
        likeCommentUseCase: sl(), unlikeCommentUseCase: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPostCommentsUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));
  sl.registerLazySingleton(() => LikeCommentUseCase(sl()));
  sl.registerLazySingleton(() => UnlikeCommentUseCase(sl()));
}
