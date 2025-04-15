import 'package:holz_logistik_backend/api/location_api.dart';

/// {@template location_api}
/// The interface for an API that provides access to locations.
/// {@endtemplate}
abstract class LocationApi {
  /// {@macro location_api}
  const LocationApi();

  /// Provides a [Stream] of all active locations.
  Stream<List<Location>> get activeLocations;

  /// Provides a [Stream] of all done locations.
  Stream<List<Location>> get doneLocations;

  /// Provides all current active locations
  List<Location> get currentActiveLocations;

  /// Provides all current done locations
  List<Location> get currentDoneLocations;

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
