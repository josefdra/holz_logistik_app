import 'dart:async';

import 'package:holz_logistik_backend/api/contract_api.dart';
import 'package:holz_logistik_backend/local_storage/contract_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

/// {@template contract_local_storage}
/// A flutter implementation of the ContractLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class ContractLocalStorage extends ContractApi {
  /// {@macro contract_local_storage}
  ContractLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(ContractTable.createTable)
      ..registerMigration(_migrateContractTable);

    _init();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _activeContractsStreamController =
      BehaviorSubject<List<Contract>>.seeded(
    const [],
  );
  late final _contractUpdatesStreamController =
      StreamController<Contract>.broadcast();

  late final Stream<List<Contract>> _activeContracts =
      _activeContractsStreamController.stream;
  late final Stream<Contract> _contractUpdates =
      _contractUpdatesStreamController.stream;

  static const _syncFromServerKey = '__contract_sync_from_server_date_key__';

  /// Migration function for contract table
  Future<void> _migrateContractTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  Future<List<Contract>> _getActiveContracts() async {
    final db = await _coreLocalStorage.database;

    final contractsJson = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnDeleted} = 0 AND '
          '${ContractTable.columnDone} = 0',
    );

    final contracts = <Contract>[];
    for (final contractJson in contractsJson) {
      final contract = Contract.fromJson(contractJson);
      contracts.add(contract);
    }

    return contracts;
  }

  /// Initialization
  Future<void> _init() async {
    final activeContracts = await _getActiveContracts();

    _activeContractsStreamController.add(activeContracts);
  }

  @override
  Stream<List<Contract>> get activeContracts => _activeContracts;

  @override
  Stream<Contract> get contractUpdates => _contractUpdates;

  /// Provides the last sync date
  @override
  Future<DateTime> getLastSyncDate() =>
      _coreLocalStorage.getLastSyncDate(_syncFromServerKey);

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(DateTime date) =>
      _coreLocalStorage.setLastSyncDate(_syncFromServerKey, date);

  /// Gets unsynced updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() =>
      _coreLocalStorage.getUpdates(ContractTable.tableName);

  @override
  Future<List<Contract>> getFinishedContractsByDate(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _coreLocalStorage.database;

    final contractsJson = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnDone} = 1 AND '
          '${ContractTable.columnDeleted} = 0 AND '
          '((${ContractTable.columnStartDate} >= ? AND '
          '${ContractTable.columnStartDate} <= ?) OR '
          '(${ContractTable.columnEndDate} >= ? AND '
          '${ContractTable.columnEndDate} <= ?))',
      whereArgs: [
        start.toUtc().millisecondsSinceEpoch,
        end.toUtc().millisecondsSinceEpoch,
        start.toUtc().millisecondsSinceEpoch,
        end.toUtc().millisecondsSinceEpoch,
      ],
    );

    final contracts = <Contract>[];
    for (final contractJson in contractsJson) {
      final contract = Contract.fromJson(contractJson);
      contracts.add(contract);
    }

    return contracts;
  }

  @override
  Future<List<Contract>> getFinishedContractsByQuery(String query) async {
    final db = await _coreLocalStorage.database;

    final contractsJson = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnDone} = 1 AND '
          '${ContractTable.columnDeleted} = 0 AND '
          '${ContractTable.columnTitle}'
          ' LIKE ?',
      whereArgs: ['%query%'],
    );

    final contracts = <Contract>[];
    for (final contractJson in contractsJson) {
      final contract = Contract.fromJson(contractJson);
      contracts.add(contract);
    }

    return contracts;
  }

  @override
  Future<Contract> getContractById(String id) async {
    final contracts = await _coreLocalStorage.getById(
      ContractTable.tableName,
      id,
    );

    return Contract.fromJson(contracts.first);
  }

  /// Insert or Update a `contract` to the database based on [contractData]
  Future<int> _insertOrUpdateContract(Map<String, dynamic> contractData) async {
    return _coreLocalStorage.insertOrUpdate(
      ContractTable.tableName,
      contractData,
    );
  }

  /// Insert or Update a [contract]
  @override
  Future<int> saveContract(Contract contract, {bool fromServer = false}) async {
    final json = contract.toJson();

    if (fromServer) {
      if (!(await _coreLocalStorage.isNewer(
        ContractTable.tableName,
        contract.lastEdit,
        contract.id,
      ))) {
        return 0;
      }

      json['synced'] = 1;
    } else {
      json['synced'] = 0;
      json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final result = await _insertOrUpdateContract(json);
    final activeContracts =
        List<Contract>.from(_activeContractsStreamController.value);

    if (contract.done == false) {
      final index = activeContracts.indexWhere((c) => c.id == contract.id);
      if (index > -1) {
        activeContracts[index] = contract;
      } else {
        activeContracts.add(contract);
      }
    } else {
      activeContracts.removeWhere((c) => c.id == contract.id);
    }

    _contractUpdatesStreamController.add(contract);
    _activeContractsStreamController.add(activeContracts);

    return result;
  }

  /// Delete a Contract from the database based on [id]
  Future<int> _deleteContract(String id) async {
    return _coreLocalStorage.delete(ContractTable.tableName, id);
  }

  /// Marks a Contract as deleted based on [id] and [done] status
  @override
  Future<int> markContractDeleted({
    required String id,
    required bool done,
  }) async {
    final resultList =
        await _coreLocalStorage.getByIdForDeletion(ContractTable.tableName, id);

    if (resultList.isEmpty) return 0;

    final contract = Contract.fromJson(resultList.first);
    final json = Map<String, dynamic>.from(resultList.first);
    json['deleted'] = 1;
    json['synced'] = 0;
    json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;

    final result = await _insertOrUpdateContract(json);

    if (done == false) {
      final contracts =
          List<Contract>.from(_activeContractsStreamController.value)
            ..removeWhere((c) => c.id == id);

      _activeContractsStreamController.add(contracts);
    }

    _contractUpdatesStreamController.add(contract);

    return result;
  }

  /// Delete a Contract based on [id]
  @override
  Future<int> deleteContract({required String id}) async {
    final result =
        await _coreLocalStorage.getByIdForDeletion(ContractTable.tableName, id);

    if (result.isEmpty) return 0;

    await _deleteContract(id);
    final contract = Contract.fromJson(result.first);

    if (contract.done == false) {
      final contracts =
          List<Contract>.from(_activeContractsStreamController.value)
            ..removeWhere((l) => l.id == id);

      _activeContractsStreamController.add(contracts);
    }

    _contractUpdatesStreamController.add(contract);

    return 0;
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id}) =>
      _coreLocalStorage.setSynced(ContractTable.tableName, id);

  /// Close the both controllers
  @override
  Future<void> close() {
    _activeContractsStreamController.close();
    return _contractUpdatesStreamController.close();
  }
}
