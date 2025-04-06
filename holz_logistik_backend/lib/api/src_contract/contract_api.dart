import 'package:holz_logistik_backend/api/src_contract/contract_models/contract.dart';

/// {@template contract_api}
/// The interface for an API that provides access to contracts.
/// {@endtemplate}
abstract class ContractApi {
  /// {@macro contract_api}
  const ContractApi();

  /// Provides a [Stream] of all contracts.
  Stream<List<Contract>> get contracts;

  /// Saves or updates a [contract].
  ///
  /// If a [contract] with the same id already exists, it will be updated.
  Future<void> saveContract(Contract contract);

  /// Deletes the `contract` with the given [id].
  ///
  /// If no `contract` with the given id exists, a [ContractNotFoundException]
  /// error is thrown.
  Future<void> deleteContract(String id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}

/// Error thrown when a [Contract] with a given id is not found.
class ContractNotFoundException implements Exception {}
