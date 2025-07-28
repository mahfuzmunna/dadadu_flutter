import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/usecases/follow_unfollow_user_usecase.dart';

// Import your use cases

part 'follow_event.dart';
part 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final FollowUserUseCase _followUserUseCase;
  final UnfollowUserUseCase _unfollowUserUseCase;

  FollowBloc({
    required FollowUserUseCase followUserUseCase,
    required UnfollowUserUseCase unfollowUserUseCase,
  })  : _followUserUseCase = followUserUseCase,
        _unfollowUserUseCase = unfollowUserUseCase,
        super(FollowInitial()) {
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
  }

  Future<void> _onFollowUser(
      FollowUser event, Emitter<FollowState> emit) async {
    emit(FollowLoading());
    final result = await _followUserUseCase(FollowUserParams(
      followerId: event.currentUserId,
      followingId: event.profileUserId,
    ));
    result.fold(
      (failure) => emit(FollowError(failure.message)),
      (_) => emit(FollowSuccess()),
    );
  }

  Future<void> _onUnfollowUser(
      UnfollowUser event, Emitter<FollowState> emit) async {
    emit(FollowLoading());
    final result = await _unfollowUserUseCase(FollowUserParams(
      followerId: event.currentUserId,
      followingId: event.profileUserId,
    ));
    result.fold(
      (failure) => emit(FollowError(failure.message)),
      (_) => emit(FollowSuccess()),
    );
  }
}
// Create corresponding event and state files
