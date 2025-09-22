import 'dart:async';

import 'package:holz_logistik_backend/general/general.dart';
import 'package:holz_logistik_backend/sync/core_sync_service.dart';

/// {@template note_sync_service}
/// A dart implementation of a synchronization service in extension to the
/// general core_sync_service.
/// {@endtemplate}
class NoteSyncService {
  /// {@macro note_sync_service}
  NoteSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerMessageHandler(
      messageType: 'note_update',
      messageHandler: _handleNoteUpdate,
    );
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _noteUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of note updates from external sources
  Stream<Map<String, dynamic>> get noteUpdates => _noteUpdateController.stream;

  void _handleNoteUpdate(dynamic data) {
    try {
      _noteUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Register a date getter
  void registerDateGetter(DateGetter dateGetter) {
    try {
      _coreSyncService.registerDateGetter(
        type: 'note_update',
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
        type: 'note_update',
        dataGetter: dataGetter,
      );
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Send note updates to server
  Future<void> sendNoteUpdate(Map<String, dynamic> data, String dbName) {
    return _coreSyncService.sendMessage('note_update', data, dbName: dbName);
  }

  /// Dispose
  void dispose() {
    _noteUpdateController.close();
  }
}
