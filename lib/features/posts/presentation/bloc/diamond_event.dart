part of 'diamond_bloc.dart';

abstract class DiamondEvent extends Equatable {
  const DiamondEvent();

  @override
  List<Object> get props => [];
}

class SendDiamond extends DiamondEvent {
  final String userId;
  final String postId;

  const SendDiamond({required this.userId, required this.postId});

  @override
  List<Object> get props => [userId, postId];
}

class UnsendDiamond extends DiamondEvent {
  final String userId;
  final String postId;

  const UnsendDiamond({required this.userId, required this.postId});

  @override
  List<Object> get props => [userId, postId];
}
