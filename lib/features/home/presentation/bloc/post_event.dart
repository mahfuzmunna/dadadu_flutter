// lib/features/home/presentation/bloc/post_event.dart
part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class LoadPost extends PostEvent {
  final String postId;

  const LoadPost(this.postId);

  @override
  List<Object> get props => [postId];
}

class UpdatePost extends PostEvent {
  final PostEntity post;

  const UpdatePost(this.post);

  @override
  List<Object> get props => [post];
}
