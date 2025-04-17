import 'dart:async';

import 'package:holz_logistik_backend/api/location_api.dart';
import 'package:holz_logistik_backend/sync/location_sync_service.dart';

/// {@template location_repository}
/// A repository that handles `location` related requests.
/// {@endtemplate}
class LocationRepository {
  /// {@macro location_repository}
  LocationRepository({
    required LocationApi locationApi,
    required LocationSyncService locationSyncService,
  })  : _locationApi = locationApi,
        _locationSyncService = locationSyncService {
    _locationSyncService.locationUpdates.listen(_handleServerUpdate);
  }

  final LocationApi _locationApi;
  final LocationSyncService _locationSyncService;

  /// Provides a [Stream] of active locations.
  Stream<List<Location>> get activeLocations => _locationApi.activeLocations;

  /// Provides updates on finished locations.
  Stream<Map<String, dynamic>> get finishedLocationUpdates =>
      _locationApi.finishedLocationUpdates;

  /// Provides finished locations.
  Future<List<Location>> getFinishedLocationsByDate(
    DateTime start,
    DateTime end,
  ) =>
      _locationApi.getFinishedLocationsByDate(start, end);

  /// Provides a single location by [id]
  Future<Location> getLocationById(String id) =>
      _locationApi.getLocationById(id);

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _locationApi.deleteLocation(
        id: data['id'] as String,
        done: data['done'] as bool,
      );
    } else {
      _locationApi.saveLocation(Location.fromJson(data));
    }
  }

  /// Saves a [location].
  ///
  /// If a [location] with the same id already exists, it will be replaced.
  Future<void> saveLocation(Location location) {
    _locationApi.saveLocation(location);
    return _locationSyncService.sendLocationUpdate(location.toJson());
  }

  /// Deletes the `location` with the given id.
  Future<void> deleteLocation({required String id, required bool done}) {
    _locationApi.deleteLocation(id: id, done: done);
    final data = {
      'id': id,
      'deleted': true,
      'done': done,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _locationSyncService.sendLocationUpdate(data);
  }

  /// Updates the current values of a location
  Future<void> updateCurrentValues(
    String locationId,
    double quantity,
    double oversizeQuantity,
    int pieceCount,
  ) async {
    final location = await _locationApi.getLocationById(locationId);
    final updatedQuantity = location.currentQuantity + quantity;
    final updatedOversizeQuantity =
        location.currentOversizeQuantity + oversizeQuantity;
    final updatedPieceCount = location.currentPieceCount + pieceCount;
    final updatedLocation = location.copyWith(
      currentQuantity: updatedQuantity,
      currentOversizeQuantity: updatedOversizeQuantity,
      currentPieceCount: updatedPieceCount,
    );
    await _locationApi.saveLocation(updatedLocation);

    return _locationSyncService.sendLocationUpdate(updatedLocation.toJson());
  }

  /// Updates the `started` status of a location
  Future<void> unsetStarted(String locationId) async {
    final location = await _locationApi.getLocationById(locationId);
    final updatedLocation = location.copyWith(started: false);
    await _locationApi.saveLocation(updatedLocation);

    return _locationSyncService.sendLocationUpdate(updatedLocation.toJson());
  }

  /// Updates the `started` status of a location
  Future<void> setStarted(String locationId) async {
    final location = await _locationApi.getLocationById(locationId);
    final updatedLocation = location.copyWith(started: true);
    await _locationApi.saveLocation(updatedLocation);

    return _locationSyncService.sendLocationUpdate(updatedLocation.toJson());
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _locationApi.close();
}
