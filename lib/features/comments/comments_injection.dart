

// Future<void> commentsInjection() async {
//   sl.registerFactory(
//     () => CommentsBloc(getPostCommentsUseCase: sl(), addCommentUseCase: sl()),
//   );
//   sl.registerFactory(
//     () => LikeUnlikeCommentBloc(
//         likeCommentUseCase: sl(), unlikeCommentUseCase: sl()),
//   );
//
//   // Use cases
//   sl.registerLazySingleton(() => GetPostCommentsUseCase(sl()));
//   sl.registerLazySingleton(() => AddCommentUseCase(sl()));
//   sl.registerLazySingleton(() => LikeCommentUseCase(sl()));
//   sl.registerLazySingleton(() => UnlikeCommentUseCase(sl()));
// }
