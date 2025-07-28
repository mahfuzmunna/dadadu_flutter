part of 'diamond_bloc.dart';

abstract class DiamondEvent extends Equatable {
  const DiamondEvent();

  @override
  List<Object> get props => [];
}

class SendDiamond extends DiamondEvent {
  final String userId;
  final String postId;
  final String authorId;

  const SendDiamond(
      {required this.userId, required this.postId, required this.authorId});

  @override
  List<Object> get props => [userId, postId, authorId];
}

class UnsendDiamond extends DiamondEvent {
  final String userId;
  final String postId;
  final String authorId;

  const UnsendDiamond(
      {required this.userId, required this.postId, required this.authorId});

  @override
  List<Object> get props => [userId, postId, authorId];
}
