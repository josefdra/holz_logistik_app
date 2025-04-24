import 'package:holz_logistik_backend/api/contract_api.dart';

/// {@template contract_api}
/// The interface for an API that provides access to contracts.
/// {@endtemplate}
abstract class ContractApi {
  /// {@macro contract_api}
  const ContractApi();

  /// Provides a [Stream] of all active contracts.
  Stream<List<Contract>> get activeContracts;

  /// Provides updates on finished contracts
  Stream<Contract> get contractUpdates;

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate();

  /// Sets the last sync date
  Future<void> setLastSyncDate(DateTime date);

  /// Gets updates
  Future<List<Map<String, dynamic>>> getUpdates();

  /// Provides finished contracts by date.
  Future<List<Contract>> getFinishedContractsByDate(
    DateTime start,
    DateTime end,
  );

  /// Provides finished contracts by search query.
  Future<List<Contract>> getFinishedContractsByQuery(String query);

  /// Provides a single contract by [id]
  Future<Contract> getContractById(String id);

  /// Saves or updates a [contract].
  ///
  /// If a [contract] with the same id already exists, it will be updated.
  Future<void> saveContract(Contract contract, {bool fromServer = false});

  /// Marks a `contract` with the given [id] and [done] status as deleted.
  Future<void> markContractDeleted({required String id, required bool done});

  /// Deletes the `contract` with the given [id].
  Future<void> deleteContract({required String id});

  /// Sets synced
  Future<void> setSynced({required String id});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
