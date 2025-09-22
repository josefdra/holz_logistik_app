import 'dart:async';

import 'package:holz_logistik_backend/sync/core_sync_service.dart';

/// {@template authentication_sync_service}
/// A dart implementation of a synchronization service for authentication
/// in extension to the general core_sync_service.
/// {@endtemplate}
class AuthenticationSyncService {
  /// {@macro authentication_sync_service}
  AuthenticationSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerMessageHandler(
      messageType: 'authentication_response',
      messageHandler: _handleAuthenticationUpdate,
    );
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _authenticationUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of authentication updates from external sources
  Stream<Map<String, dynamic>> get authenticationUpdates =>
      _authenticationUpdateController.stream;

  void _handleAuthenticationUpdate(dynamic data) {
    try {
      _authenticationUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Releases the sync lock after database update
  void releaseLock(){
    _coreSyncService.releaseLock();
  }

  /// Dispose
  void dispose() {
    _authenticationUpdateController.close();
  }
}
