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

  /// Gets the active database name
  String get dbName;

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate();

  /// Sets the last sync date
  Future<void> setLastSyncDate(String dbName, DateTime date);

  /// Gets updates
  Future<List<Map<String, dynamic>>> getUpdates();

  /// Provides finished locations.
  Future<List<Location>> getFinishedLocationsByDate(
    DateTime start,
    DateTime end,
  );

  /// Get partieNr by id
  Future<String> getPartieNrById(String id);

  /// Provides a single location by [id]
  Future<Location> getLocationById(String id);

  /// Saves or updates a [location].
  ///
  /// If a [location] with the same id already exists, it will be updated.
  Future<void> saveLocation(
    Location location, {
    bool fromServer = false,
    String? dbName,
  });

  /// Marks a `location` with the given [id] and [done] status as deleted.
  Future<void> markLocationDeleted({required String id, required bool done});

  /// Deletes the `location` with the given [id].
  Future<void> deleteLocation({required String id, required String dbName});

  /// Sets synced
  Future<void> setSynced({required String id, required String dbName});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
