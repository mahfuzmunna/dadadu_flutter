// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Abstract base class for all use cases.
/// [Type] is the return type of the use case.
/// [Params] is the type of the parameters required by the use case.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// A class for use cases that don't require any parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}