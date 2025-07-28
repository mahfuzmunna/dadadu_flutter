part of 'discover_bloc.dart';

abstract class DiscoverEvent extends Equatable {}

class FindUsersByVibe extends DiscoverEvent {
  final String vibe;
  final Position position;
  final double distance;

  FindUsersByVibe(
      {required this.vibe, required this.position, required this.distance});

  @override
  List<Object?> get props => [vibe, position, distance];
}
