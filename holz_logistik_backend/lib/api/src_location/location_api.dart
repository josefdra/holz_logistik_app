import 'package:holz_logistik_backend/api/location_api.dart';

/// {@template location_api}
/// The interface for an API that provides access to locations.
/// {@endtemplate}
abstract class LocationApi {
  /// {@macro location_api}
  const LocationApi();

  /// Provides a [Stream] of all active locations.
  Stream<List<Location>> get activeLocations;

  /// Provides updates on finished locations.
  Stream<Location> get locationUpdates;

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate(String type);

  /// Sets the last sync date
  Future<void> setLastSyncDate(String type, DateTime date);

  /// Gets updates
  Future<List<Map<String, dynamic>>> getUpdates();

  /// Provides finished locations.
  Future<List<Location>> getFinishedLocationsByDate(
      DateTime start, DateTime end,);

  /// Provides a single location by [id]
  Future<Location> getLocationById(String id);

  /// Saves or updates a [location].
  ///
  /// If a [location] with the same id already exists, it will be updated.
  Future<void> saveLocation(Location location);

  /// Deletes the `location` with the given [id].
  Future<void> deleteLocation({required String id, required bool done});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
