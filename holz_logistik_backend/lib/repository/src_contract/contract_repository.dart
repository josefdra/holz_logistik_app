import 'dart:async';

import 'package:holz_logistik_backend/api/contract_api.dart';
import 'package:holz_logistik_backend/general/general.dart';
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
    _init();
  }

  final ContractApi _contractApi;
  final ContractSyncService _contractSyncService;

  /// Provides a [Stream] of active contracts.
  Stream<List<Contract>> get activeContracts => _contractApi.activeContracts;

  /// Provides a [Stream] of updates on finished contracts.
  Stream<Contract> get contractUpdates => _contractApi.contractUpdates;

  void _init() {
    _contractSyncService
      ..registerDateGetter(_contractApi.getLastSyncDate)
      ..registerDataGetter(_contractApi.getUpdates);
  }

  /// Provides finished contracts by date.
  Future<List<Contract>> getFinishedContractsByDate(
    DateTime start,
    DateTime end,
  ) =>
      _contractApi.getFinishedContractsByDate(start, end);

  /// Provides finished contracts by search query.
  Future<List<Contract>> getFinishedContractsByQuery(String query) =>
      _contractApi.getFinishedContractsByQuery(query);

  /// Provides a single contract by [id]
  Future<Contract> getContractById(String id) =>
      _contractApi.getContractById(id);

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data.containsKey('newSyncDate')) {
      _contractApi.setLastSyncDate(
        DateTime.fromMillisecondsSinceEpoch(
          data['newSyncDate'] as int,
          isUtc: true,
        ),
      );
    } else if (data['deleted'] == true || data['deleted'] == 1) {
      _contractApi.deleteContract(
        id: data['id'] as String,
      );
    } else if (data['synced'] == true || data['synced'] == 1) {
      _contractApi.setSynced(id: data['id'] as String);
    } else {
      final contract = Contract.fromJson(data);
      _contractApi.saveContract(contract, fromServer: true);
    }
  }

  /// Saves a [contract].
  ///
  /// If a [contract] with the same id already exists, it will be updated.
  Future<void> saveContract(Contract contract) {
    final updatedContract = contract.copyWith(
      availableQuantity: customRound(contract.availableQuantity),
      bookedQuantity: customRound(contract.bookedQuantity),
      shippedQuantity: customRound(contract.shippedQuantity),
      lastEdit: DateTime.now(),
    );
    _contractApi.saveContract(updatedContract);
    return _contractSyncService.sendContractUpdate(updatedContract.toJson());
  }

  /// Deletes the `contract` with the given id.
  Future<void> deleteContract({required String id, required bool done}) async {
    await _contractApi.markContractDeleted(id: id, done: done);
    final data = {
      'id': id,
      'deleted': 1,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };

    return _contractSyncService.sendContractUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _contractApi.close();
}
