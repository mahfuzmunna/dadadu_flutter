import 'package:dadadu_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class LocationRepository {
  /// Fetches a human-readable location name from geographic coordinates.
  ///
  /// Returns a [String] (e.g., "Tangail, Dhaka Division") on success.
  /// Returns a [Failure] on error.
  Future<Either<Failure, String>> getLocationName(
      double latitude, double longitude);
}
