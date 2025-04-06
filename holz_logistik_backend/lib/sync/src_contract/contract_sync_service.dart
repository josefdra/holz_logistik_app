import 'dart:async';

import 'package:holz_logistik_backend/sync/core_sync_service.dart';

/// {@template contract_sync_service}
/// A dart implementation of a synchronization service in extension to the
/// general core_sync_service.
/// {@endtemplate}
class ContractSyncService {
  /// {@macro contract_sync_service}
  ContractSyncService({
    required CoreSyncService coreSyncService,
  }) : _coreSyncService = coreSyncService {
    _coreSyncService.registerHandler('contract_update', _handleContractUpdate);
  }

  final CoreSyncService _coreSyncService;

  // StreamController to broadcast updates received from WebSocket
  final _contractUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of contract updates from external sources
  Stream<Map<String, dynamic>> get contractUpdates =>
      _contractUpdateController.stream;

  void _handleContractUpdate(dynamic data) {
    try {
      _contractUpdateController.add(data as Map<String, dynamic>);
    } catch (e) {
      // Handle parsing errors
    }
  }

  /// Send contract updates to server
  Future<void> sendContractUpdate(Map<String, dynamic> data) {
    return _coreSyncService.sendMessage('contract_update', data);
  }

  /// Dispose
  void dispose() {
    _contractUpdateController.close();
  }
}
