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
  late final _finishedContractUpdatesStreamController =
      BehaviorSubject<Map<String, dynamic>>.seeded(
    const {},
  );

  late final Stream<List<Contract>> _activeContracts =
      _activeContractsStreamController.stream;
  late final Stream<Map<String, dynamic>> _finishedContractUpdates =
      _finishedContractUpdatesStreamController.stream;

  /// Migration function for contract table
  Future<void> _migrateContractTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  Future<List<Contract>> _getContractsByCondition({
    required bool isDone,
  }) async {
    final db = await _coreLocalStorage.database;

    final contractsJson = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnDone} = ?',
      whereArgs: [if (isDone) 1 else 0],
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
    final activeContracts = await _getContractsByCondition(isDone: false);

    _activeContractsStreamController.add(activeContracts);
  }

  @override
  Stream<List<Contract>> get activeContracts => _activeContracts;

  @override
  Stream<Map<String, dynamic>> get finishedContractUpdates =>
      _finishedContractUpdates;

  @override
  Future<List<Contract>> getFinishedContractsByDate(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _coreLocalStorage.database;

    final contractsJson = await db.query(
      ContractTable.tableName,
      where:
          '${ContractTable.columnDone} = ? AND ${ContractTable.columnStartDate}'
          ' >= ? AND ${ContractTable.columnStartDate} <= ? OR '
          '${ContractTable.columnEndDate} >= ? AND '
          '${ContractTable.columnEndDate} <= ?',
      whereArgs: [1, start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
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
      where: '${ContractTable.columnDone} = ? AND ${ContractTable.columnTitle}'
          ' LIKE ?',
      whereArgs: [1, '%query%'],
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
  Future<int> saveContract(Contract contract) async {
    final result = await _insertOrUpdateContract(contract.toJson());
    final activeController = _activeContractsStreamController;
    final activeContracts = List<Contract>.from(activeController.value);

    if (contract.done == false) {
      final index = activeContracts.indexWhere((c) => c.id == contract.id);
      if (index > -1) {
        activeContracts[index] = contract;
      } else {
        activeContracts.add(contract);
      }
    } else {
      activeContracts.removeWhere((c) => c.id == contract.id);
      final updateController = _finishedContractUpdatesStreamController;
      final updateData = {
        'startDate': contract.startDate,
        'endDate': contract.endDate,
        'title': contract.title,
      };

      updateController.add(updateData);
    }

    activeController.add(activeContracts);

    return result;
  }

  /// Delete a Contract from the database based on [id]
  Future<int> _deleteContract(String id) async {
    return _coreLocalStorage.delete(ContractTable.tableName, id);
  }

  /// Delete a Contract based on [id] and [done] status
  @override
  Future<int> deleteContract({required String id, required bool done}) async {
    final contract = await getContractById(id);
    final result = await _deleteContract(id);

    if (done == false) {
      final controller = _activeContractsStreamController;
      final contracts = List<Contract>.from(controller.value)
        ..removeWhere((c) => c.id == id);

      controller.add(contracts);
    } else {
      final controller = _finishedContractUpdatesStreamController;
      final updateData = {
        'startDate': contract.startDate,
        'endDate': contract.endDate,
        'title': contract.title,
      };

      controller.add(updateData);
    }

    return result;
  }

  /// Close the both controllers
  @override
  Future<void> close() {
    _activeContractsStreamController.close();
    return _finishedContractUpdatesStreamController.close();
  }
}
