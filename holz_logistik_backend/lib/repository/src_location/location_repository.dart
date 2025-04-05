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

  /// Provides a [Stream] of all locations.
  Stream<List<Location>> getLocations() => _locationApi.locations;

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _locationApi.deleteLocation(data['id'] as int);
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
  ///
  /// If no `location` with the given id exists, a [LocationNotFoundException] 
  /// error is thrown.
  Future<void> deleteLocation(int id) {
    _locationApi.deleteLocation(id);
    final data = {
      'id': id,
      'deleted': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _locationSyncService.sendLocationUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _locationApi.close();
}
