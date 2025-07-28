part of 'diamond_bloc.dart';

abstract class DiamondState extends Equatable {
  const DiamondState();

  @override
  List<Object> get props => [];
}

class DiamondInitial extends DiamondState {}

class DiamondLoading extends DiamondState {}

class DiamondSuccess extends DiamondState {}

class DiamondFailure extends DiamondState {
  final String message;

  const DiamondFailure(this.message);
}

class DiamondError extends DiamondState {
  final String message;

  const DiamondError(this.message);

  @override
  List<Object> get props => [message];
}
