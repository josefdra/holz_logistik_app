import 'package:holz_logistik_backend/api/src_contract/contract_models/contract.dart';

/// {@template contract_api}
/// The interface for an API that provides access to contracts.
/// {@endtemplate}
abstract class ContractApi {
  /// {@macro contract_api}
  const ContractApi();

  /// Provides a [Stream] of all active contracts.
  Stream<Map<String, Contract>> get activeContracts;

  /// Provides a [Stream] of all finished contracts.
  Stream<Map<String, Contract>> get doneContracts;

  /// Provides all current active contracts.
  Map<String, Contract> get currentActiveContracts;

  /// Provides a current finished contracts.
  Map<String, Contract> get currentDoneContracts;

  /// Provides a single contract by [id]
  Future<Contract> getContractById(String id);

  /// Saves or updates a [contract].
  ///
  /// If a [contract] with the same id already exists, it will be updated.
  Future<void> saveContract(Contract contract);

  /// Deletes the `contract` with the given [id] and [done] status.
  Future<void> deleteContract({required String id, required bool done});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
