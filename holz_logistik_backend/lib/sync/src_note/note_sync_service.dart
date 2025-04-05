import 'dart:async';

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
    _coreSyncService.registerHandler('note_update', _handleNoteUpdate);
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

  /// Send note updates to server
  Future<void> sendNoteUpdate(Map<String, dynamic> data) {
    return _coreSyncService.sendMessage('note_update', data);
  }

  /// Dispose
  void dispose() {
    _noteUpdateController.close();
  }
}
