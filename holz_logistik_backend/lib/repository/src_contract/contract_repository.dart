import 'dart:async';

import 'package:holz_logistik_backend/api/contract_api.dart';
import 'package:holz_logistik_backend/sync/contract_sync_service.dart';

/// {@template contract_repository}
/// A repository that handles `contract` related requests.
/// {@endtemplate}
class ContractRepository {
  /// {@macro contract_repository}
  ContractRepository({
    required ContractApi contractApi,
    required ContractSyncService contractSyncService,
  })  : _contractApi = contractApi,
        _contractSyncService = contractSyncService {
    _contractSyncService.contractUpdates.listen(_handleServerUpdate);
  }

  final ContractApi _contractApi;
  final ContractSyncService _contractSyncService;

  /// Provides a [Stream] of all contracts.
  Stream<List<Contract>> get contracts => _contractApi.contracts;

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _contractApi.deleteContract(data['id'] as int);
    } else {
      _contractApi.saveContract(Contract.fromJson(data));
    }
  }

  /// Saves a [contract].
  ///
  /// If a [contract] with the same id already exists, it will be updated.
  Future<void> saveContract(Contract contract) {
    _contractApi.saveContract(contract);
    return _contractSyncService.sendContractUpdate(contract.toJson());
  }

  /// Deletes the `contract` with the given id.
  ///
  /// If no `contract` with the given id exists, a [ContractNotFoundException] 
  /// error is thrown.
  Future<void> deleteContract(int id) {
    _contractApi.deleteContract(id);
    final data = {
      'id': id,
      'deleted': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _contractSyncService.sendContractUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _contractApi.close();
}
