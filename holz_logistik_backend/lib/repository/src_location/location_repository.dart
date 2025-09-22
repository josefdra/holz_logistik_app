import 'dart:async';

import 'package:holz_logistik_backend/api/location_api.dart';
import 'package:holz_logistik_backend/general/general.dart';
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
    _init();
  }

  final LocationApi _locationApi;
  final LocationSyncService _locationSyncService;

  /// Provides a [Stream] of active locations.
  Stream<List<Location>> get activeLocations => _locationApi.activeLocations;

  /// Provides updates on finished locations.
  Stream<Location> get locationUpdates => _locationApi.locationUpdates;

  void _init() {
    _locationSyncService
      ..registerDateGetter(_locationApi.getLastSyncDate)
      ..registerDataGetter(_locationApi.getUpdates);
  }

  /// Provides finished locations.
  Future<List<Location>> getFinishedLocationsByDate(
    DateTime start,
    DateTime end,
  ) =>
      _locationApi.getFinishedLocationsByDate(start, end);

  /// Get PartieNr by id
  Future<String> getPartieNrById(String id) => _locationApi.getPartieNrById(id);

  /// Provides a single location by [id]
  Future<Location> getLocationById(String id) =>
      _locationApi.getLocationById(id);

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data.containsKey('newSyncDate')) {
      _locationApi.setLastSyncDate(
        data['dbName'] as String,
        DateTime.fromMillisecondsSinceEpoch(
          data['newSyncDate'] as int,
          isUtc: true,
        ),
      );
    } else if (data['deleted'] == true || data['deleted'] == 1) {
      _locationApi.deleteLocation(
        id: data['id'] as String,
        dbName: data['dbName'] as String,
      );
    } else if (data['synced'] == true || data['synced'] == 1) {
      _locationApi.setSynced(
        id: data['id'] as String,
        dbName: data['dbName'] as String,
      );
    } else {
      final location = Location.fromJson(data);
      _locationApi.saveLocation(location, fromServer: true);
    }
  }

  /// Saves a [location].
  ///
  /// If a [location] with the same id already exists, it will be replaced.
  Future<void> saveLocation(Location location) {
    final updatedLocation = location.copyWith(
      initialQuantity: customRound(location.initialQuantity),
      initialOversizeQuantity: customRound(location.initialOversizeQuantity),
      currentQuantity: customRound(location.currentQuantity),
      currentOversizeQuantity: customRound(location.currentOversizeQuantity),
      lastEdit: DateTime.now(),
    );
    _locationApi.saveLocation(updatedLocation);
    final dbName = _locationApi.dbName;

    return _locationSyncService.sendLocationUpdate(
      updatedLocation.toJson(),
      dbName,
    );
  }

  /// Deletes the `location` with the given id.
  Future<void> deleteLocation({required String id, required bool done}) async {
    await _locationApi.markLocationDeleted(id: id, done: done);
    final data = {
      'id': id,
      'deleted': 1,
      'done': done,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
    final dbName = _locationApi.dbName;

    return _locationSyncService.sendLocationUpdate(data, dbName);
  }

  /// Updates the values based on a shipment
  Future<void> addShipment(
    String locationId,
    double quantity,
    double oversizeQuantity,
    int pieceCount,
    double currentQuantity,
    double currentOversizeQuantity,
    int currentPieceCount, {
    required bool locationFinished,
  }) async {
    final location = await _locationApi.getLocationById(locationId);

    final updatedInitialQuantity = location.initialQuantity +
        currentQuantity -
        (location.currentQuantity - quantity);

    final updatedInitialOversizeQuantity = location.initialOversizeQuantity +
        currentOversizeQuantity -
        (location.currentOversizeQuantity - oversizeQuantity);

    final updatedInitialPieceCount = location.initialPieceCount +
        currentPieceCount -
        (location.currentPieceCount - pieceCount);

    final updatedLocationFinished = locationFinished
        ? locationFinished
        : (currentQuantity == 0);

    final updatedLocation = location.copyWith(
      initialQuantity: updatedInitialQuantity,
      initialOversizeQuantity: updatedInitialOversizeQuantity,
      initialPieceCount: updatedInitialPieceCount,
      currentQuantity: currentQuantity,
      currentOversizeQuantity: currentOversizeQuantity,
      currentPieceCount: currentPieceCount,
      started: true,
      done: updatedLocationFinished,
    );
    await saveLocation(updatedLocation);
  }

  /// Updates the values based on a shipment
  Future<void> removeShipment(
    String locationId,
    double quantity,
    double oversizeQuantity,
    int pieceCount, {
    required bool started,
  }) async {
    final location = await _locationApi.getLocationById(locationId);
    final updatedQuantity = location.currentQuantity + quantity;
    final updatedOversizeQuantity =
        location.currentOversizeQuantity + oversizeQuantity;
    final updatedPieceCount = location.currentPieceCount + pieceCount;
    final updatedLocationFinished =
        (updatedQuantity == 0) || updatedPieceCount == 0;
    final updatedLocation = location.copyWith(
      currentQuantity: updatedQuantity,
      currentOversizeQuantity: updatedOversizeQuantity,
      currentPieceCount: updatedPieceCount,
      started: started,
      done: updatedLocationFinished,
    );
    await saveLocation(updatedLocation);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _locationApi.close();
}
