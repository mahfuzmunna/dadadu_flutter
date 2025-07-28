import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Make sure to create and import your use cases
import '../../domain/usecases/send_unsend_diamond_usecase.dart';

part 'diamond_event.dart';
part 'diamond_state.dart';

class DiamondBloc extends Bloc<DiamondEvent, DiamondState> {
  final SendDiamondUseCase _sendDiamondUseCase;
  final UnsendDiamondUseCase _unsendDiamondUseCase;

  DiamondBloc({
    required SendDiamondUseCase sendDiamondUseCase,
    required UnsendDiamondUseCase unsendDiamondUseCase,
  })  : _sendDiamondUseCase = sendDiamondUseCase,
        _unsendDiamondUseCase = unsendDiamondUseCase,
        super(DiamondInitial()) {
    on<SendDiamond>(_onSendDiamond);
    on<UnsendDiamond>(_onUnsendDiamond);
  }

  Future<void> _onSendDiamond(
      SendDiamond event, Emitter<DiamondState> emit) async {
    emit(DiamondLoading());
    final result = await _sendDiamondUseCase(SendDiamondParams(
      userId: event.userId,
      postId: event.postId,
      authorId: event.authorId,
    ));
    result.fold(
      (failure) => emit(DiamondError(failure.message)),
      (_) => emit(DiamondSuccess()),
    );
  }

  Future<void> _onUnsendDiamond(
      UnsendDiamond event, Emitter<DiamondState> emit) async {
    emit(DiamondLoading());
    final result = await _unsendDiamondUseCase(SendDiamondParams(
      userId: event.userId,
      postId: event.postId,
      authorId: event.authorId,
    ));
    result.fold(
      (failure) => emit(DiamondError(failure.message)),
      (_) => emit(DiamondSuccess()),
    );
  }
}
