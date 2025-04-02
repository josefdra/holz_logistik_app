import 'dart:async';

import 'package:core_sync_service/core_sync_service.dart';

/// {@template user_sync_service}
/// A dart implementation of a synchronization service in extension to the
/// general core_sync_service.
/// {@endtemplate}
class UserSyncService {
  /// {@macro user_sync_service}
  UserSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerHandler('user_update', _handleUserUpdate);
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _userUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of user updates from external sources
  Stream<Map<String, dynamic>> get userUpdates => _userUpdateController.stream;

  void _handleUserUpdate(dynamic data) {
    try {
      _userUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Send user updates to server
  Future<void> sendUserUpdate(Map<String, dynamic> data) {
    return _coreSyncService.sendMessage('user_update', data);
  }

  /// Send user deletion to server
  Future<void> sendUserDeletion(Map<String, dynamic> data) {
    return _coreSyncService.sendMessage('user_update', data);
  }

  /// Dispos
  void dispose() {
    _userUpdateController.close();
  }
}
