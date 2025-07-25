part of 'discover_bloc.dart';

abstract class DiscoverEvent extends Equatable {}

class FindUsersByVibe extends DiscoverEvent {
  final String vibe;
  final Position position;

  FindUsersByVibe({required this.vibe, required this.position});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
