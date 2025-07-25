// In discover_state.dart
part of 'discover_bloc.dart';

abstract class DiscoverState extends Equatable {
  /*...*/
}

class DiscoverInitial extends DiscoverState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
/*...*/
}

class DiscoverLoading extends DiscoverState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
/*...*/
}

class DiscoverUsersLoaded extends DiscoverState {
  final List<UserWithDistance> users;

  DiscoverUsersLoaded(this.users);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class DiscoverError extends DiscoverState {
  final String message;

  DiscoverError(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
