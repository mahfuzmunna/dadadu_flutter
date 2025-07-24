// lib/features/now/presentation/bloc/post_state.dart
part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];

  get message => null;
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostError extends PostState {
  final String message;

  const PostError(this.message);

  @override
  List<Object> get props => [message];
}

class PostLoaded extends PostState {
  final PostEntity? post;
  final UserEntity? author;

  const PostLoaded({
    required this.post,
    required this.author,
  });

  /// Creates a new instance of PostLoaded by replacing the existing properties
  /// with the provided ones. This is key for immutable state updates.
  PostLoaded copyWith({
    PostEntity? post,
    UserEntity? author,
  }) {
    return PostLoaded(
      post: post ?? this.post,
      author: author ?? this.author,
    );
  }

  @override
  List<Object?> get props => [post, author];
}
