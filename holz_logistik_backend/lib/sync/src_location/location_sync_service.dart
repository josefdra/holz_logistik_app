import 'dart:async';

import 'package:holz_logistik_backend/general/general.dart';
import 'package:holz_logistik_backend/sync/core_sync_service.dart';

/// {@template location_sync_service}
/// A dart implementation of a synchronization service in extension to the
/// general core_sync_service.
/// {@endtemplate}
class LocationSyncService {
  /// {@macro location_sync_service}
  LocationSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerMessageHandler(
      messageType: 'location_update',
      messageHandler: _handleLocationUpdate,
    );
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _locationUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of location updates from external sources
  Stream<Map<String, dynamic>> get locationUpdates =>
      _locationUpdateController.stream;

  void _handleLocationUpdate(dynamic data) {
    try {
      _locationUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Register a date getter
  void registerDateGetter(DateGetter dateGetter) {
    try {
      _coreSyncService.registerDateGetter(
        type: 'location_update',
        dateGetter: dateGetter,
      );
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Register a date setter
  void registerDateSetter(DateSetter dateSetter) {
    try {
      _coreSyncService.registerDateSetter(
        type: 'location_update',
        dateSetter: dateSetter,
      );
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Register a date setter
  void registerDataGetter(DataGetter dataGetter) {
    try {
      _coreSyncService.registerDataGetter(
        type: 'location_update',
        dataGetter: dataGetter,
      );
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Send location updates to server
  Future<void> sendLocationUpdate(Map<String, dynamic> data) {
    return _coreSyncService.sendMessage('location_update', data);
  }

  /// Dispose
  void dispose() {
    _locationUpdateController.close();
  }
}
