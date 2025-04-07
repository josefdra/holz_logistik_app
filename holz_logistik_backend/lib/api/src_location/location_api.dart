import 'package:holz_logistik_backend/api/location_api.dart';

/// {@template location_api}
/// The interface for an API that provides access to locations.
/// {@endtemplate}
abstract class LocationApi {
  /// {@macro location_api}
  const LocationApi();

  /// Provides a [Stream] of all locations.
  Stream<List<Location>> get locations;

  /// Saves or updates a [location].
  ///
  /// If a [location] with the same id already exists, it will be updated.
  Future<void> saveLocation(Location location);

  /// Deletes the `location` with the given [id].
  ///
  /// If no `location` with the given id exists, a [LocationNotFoundException] 
  /// error is thrown.
  Future<void> deleteLocation(String id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}

/// Error thrown when a [Location] with a given id is not found.
class LocationNotFoundException implements Exception {}
