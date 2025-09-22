import 'dart:async';

import 'package:holz_logistik_backend/general/general.dart';
import 'package:holz_logistik_backend/sync/core_sync_service.dart';

/// {@template sawmill_sync_service}
/// A dart implementation of a synchronization service in extension to the
/// general core_sync_service.
/// {@endtemplate}
class SawmillSyncService {
  /// {@macro sawmill_sync_service}
  SawmillSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerMessageHandler(
      messageType: 'sawmill_update',
      messageHandler: _handleSawmillUpdate,
    );
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _sawmillUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of sawmill updates from external sources
  Stream<Map<String, dynamic>> get sawmillUpdates =>
      _sawmillUpdateController.stream;

  void _handleSawmillUpdate(dynamic data) {
    try {
      _sawmillUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Register a date getter
  void registerDateGetter(DateGetter dateGetter) {
    try {
      _coreSyncService.registerDateGetter(
        type: 'sawmill_update',
        dateGetter: dateGetter,
      );
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Register a date setter
  void registerDataGetter(DataGetter dataGetter) {
    try {
      _coreSyncService.registerDataGetter(
        type: 'sawmill_update',
        dataGetter: dataGetter,
      );
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Send sawmill updates to server
  Future<void> sendSawmillUpdate(Map<String, dynamic> data, String dbName) {
    return _coreSyncService.sendMessage('sawmill_update', data, dbName: dbName);
  }

  /// Dispose
  void dispose() {
    _sawmillUpdateController.close();
  }
}
