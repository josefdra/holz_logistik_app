import 'dart:async';

import 'package:holz_logistik_backend/sync/core_sync_service.dart';

/// {@template comment_sync_service}
/// A dart implementation of a synchronization service in extension to the
/// general core_sync_service.
/// {@endtemplate}
class CommentSyncService {
  /// {@macro comment_sync_service}
  CommentSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerHandler('comment_update', _handleCommentUpdate);
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _commentUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of comment updates from external sources
  Stream<Map<String, dynamic>> get commentUpdates =>
      _commentUpdateController.stream;

  void _handleCommentUpdate(dynamic data) {
    try {
      _commentUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Send comment updates to server
  Future<void> sendCommentUpdate(Map<String, dynamic> data) {
    return _coreSyncService.sendMessage('comment_update', data);
  }

  /// Dispose
  void dispose() {
    _commentUpdateController.close();
  }
}
