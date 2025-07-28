part of 'diamond_bloc.dart';

abstract class DiamondEvent extends Equatable {
  const DiamondEvent();

  @override
  List<Object> get props => [];
}

class SendDiamond extends DiamondEvent {
  final String senderId;
  final String receiverId;

  const SendDiamond({required this.senderId, required this.receiverId});

  @override
  List<Object> get props => [senderId, receiverId];
}

class UnsendDiamond extends DiamondEvent {
  final String senderId;
  final String receiverId;

  const UnsendDiamond({required this.senderId, required this.receiverId});

  @override
  List<Object> get props => [senderId, receiverId];
}
