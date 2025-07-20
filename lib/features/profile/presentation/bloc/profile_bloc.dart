import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../../core/usecases/usecase.dart'; // For NoParams if needed

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UpdateUserModeEmoji>(_onUpdateUserModeEmoji);
  }

  Future<void> _onLoadUserProfile(
      LoadUserProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await getUserProfileUseCase(GetUserProfileParams(uid: event.uid));
    result.fold(
          (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
          (user) => emit(ProfileLoaded(user: user)),
    );
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading()); // Can also emit ProfileLoaded with current data before loading
    final result = await updateProfileUseCase(UpdateProfileParams(user: event.user));
    result.fold(
          (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
          (_) => emit(ProfileUpdated(user: event.user)), // Assuming update was successful, reflect changes
    );
  }

  Future<void> _onUpdateUserModeEmoji(
      UpdateUserModeEmoji event, Emitter<ProfileState> emit) async {
    if (state is ProfileLoaded) {
      final currentUser = (state as ProfileLoaded).user;
      final updatedUser = currentUser.copyWith(userModeEmoji: event.emoji);

      emit(ProfileLoading()); // Show loading while updating
      final result = await updateProfileUseCase(UpdateProfileParams(user: updatedUser));
      result.fold(
            (failure) => emit(ProfileError(message: _mapFailureToMessage(failure))),
            (_) => emit(ProfileUpdated(user: updatedUser)),
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return 'Cache Error';
    }
    return 'Unexpected Error';
  }
}