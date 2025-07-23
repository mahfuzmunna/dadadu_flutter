import 'package:dadadu_app/core/errors/exceptions.dart';
import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dadadu_app/features/location/data/datasources/location_remote_data_source.dart';
import 'package:dadadu_app/features/location/domain/repositories/location_repository.dart';
import 'package:dartz/dartz.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> getLocationName(
      double latitude, double longitude) async {
    try {
      final locationName =
          await remoteDataSource.getLocationName(latitude, longitude);
      return Right(locationName);
    } on ServerException catch (e) {
      // Forward specific server exceptions
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      // Catch any other unexpected errors
      return Left(ServerFailure('Failed to retrieve location name: $e'));
    }
  }
}
