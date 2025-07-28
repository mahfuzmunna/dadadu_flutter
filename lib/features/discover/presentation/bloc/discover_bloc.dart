import 'package:bloc/bloc.dart';
import 'package:dadadu_app/features/discover/domain/usecases/find_users_by_vibe_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

part 'discover_event.dart';
part 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final FindUsersByVibeUseCase _findUsersByVibeUseCase;

  DiscoverBloc({required FindUsersByVibeUseCase findUsersByVibeUseCase})
      : _findUsersByVibeUseCase = findUsersByVibeUseCase,
        super(DiscoverInitial()) {
    on<FindUsersByVibe>(_onFindUsersByVibe);
  }

  Future<void> _onFindUsersByVibe(
    FindUsersByVibe event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(DiscoverLoading());
    final result = await _findUsersByVibeUseCase(FindUsersByVibeParams(
      vibe: event.vibe,
      currentLatitude: event.position.latitude,
      currentLongitude: event.position.longitude,
      maxDistanceInKm: event.distance,
    ));
    result.fold(
      (failure) => emit(DiscoverError(failure.message)),
      (users) => emit(DiscoverUsersLoaded(users)),
    );
  }
}
