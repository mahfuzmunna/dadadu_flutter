import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/core/usecases/usecase.dart';
import 'package:dadadu_app/features/location/domain/repositories/location_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetLocationNameUseCase implements UseCase<String, GetLocationNameParams> {
  final LocationRepository repository;

  GetLocationNameUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(GetLocationNameParams params) async {
    return await repository.getLocationName(params.lat, params.lon);
  }
}

class GetLocationNameParams extends Equatable {
  final double lat;
  final double lon;

  const GetLocationNameParams({required this.lat, required this.lon});

  @override
  List<Object> get props => [lat, lon];
}
