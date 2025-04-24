import 'dart:async';

import 'package:holz_logistik_backend/general/general.dart';
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
    _coreSyncService.registerMessageHandler(
      messageType: 'contract_update',
      messageHandler: _handleContractUpdate,
    );
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

  /// Register a date getter
  void registerDateGetter(DateGetter dateGetter) {
    try {
      _coreSyncService.registerDateGetter(
        type: 'contract_update',
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
        type: 'contract_update',
        dataGetter: dataGetter,
      );
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
