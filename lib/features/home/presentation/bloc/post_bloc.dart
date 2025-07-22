// lib/features/home/presentation/bloc/post_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/upload/domain/entities/post_entity.dart';
import 'package:dadadu_app/features/upload/domain/repositories/post_repository.dart';
import 'package:equatable/equatable.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;
  StreamSubscription? _postSubscription;

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    on<LoadPost>(_onLoadPost);
    on<UpdatePost>(_onUpdatePost);
  }

  Future<void> _onLoadPost(LoadPost event, Emitter<PostState> emit) async {
    emit(PostLoading());
    _postSubscription?.cancel(); // Cancel any existing subscription

    _postSubscription =
        postRepository.subscribeToPostChanges(event.postId).listen(
      (post) {
        add(UpdatePost(post)); // Dispatch UpdatePost event on change
      },
      onError: (error) {
        emit(PostError(message: error.toString()));
      },
    );
  }

  void _onUpdatePost(UpdatePost event, Emitter<PostState> emit) {
    emit(PostLoaded(event.post));
  }

  @override
  Future<void> close() {
    _postSubscription?.cancel();
    return super.close();
  }
}
