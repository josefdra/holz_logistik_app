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
  late final _activeContractStreamController =
      BehaviorSubject<Map<String, Contract>>.seeded(
    const {},
  );
  late final _doneContractStreamController =
      BehaviorSubject<Map<String, Contract>>.seeded(
    const {},
  );

  /// Migration function for contract table
  Future<void> _migrateContractTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  Future<Map<String, Contract>> _getContractsByCondition({
    required bool isDone,
  }) async {
    final db = await _coreLocalStorage.database;

    final contractsJson = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnDone} = ?',
      whereArgs: [if (isDone) 1 else 0],
    );

    final contractsMap = <String, Contract>{};
    for (final contractJson in contractsJson) {
      final contract =
          Contract.fromJson(Map<String, dynamic>.from(contractJson));
      contractsMap[contract.id] = contract;
    }
    return contractsMap;
  }

  /// Initialization
  Future<void> _init() async {
    final activeContracts = await _getContractsByCondition(isDone: false);
    final doneContracts = await _getContractsByCondition(isDone: true);

    _activeContractStreamController.add(activeContracts);
    _doneContractStreamController.add(doneContracts);
  }

  @override
  Stream<Map<String, Contract>> get activeContracts =>
      _activeContractStreamController.asBroadcastStream();

  @override
  Stream<Map<String, Contract>> get doneContracts =>
      _doneContractStreamController.asBroadcastStream();

  @override
  Map<String, Contract> get currentActiveContracts =>
      _activeContractStreamController.value;

  @override
  Map<String, Contract> get currentDoneContracts =>
      _doneContractStreamController.value;

  /// Insert or Update a `contract` to the database based on [contractData]
  Future<int> _insertOrUpdateContract(Map<String, dynamic> contractData) async {
    return _coreLocalStorage.insertOrUpdate(
      ContractTable.tableName,
      contractData,
    );
  }

  /// Insert or Update a [contract]
  @override
  Future<int> saveContract(Contract contract) {
    late final BehaviorSubject<Map<String, Contract>> controller;

    if (contract.done == false) {
      controller = _activeContractStreamController;
    } else {
      controller = _doneContractStreamController;
    }

    final contracts = Map<String, Contract>.from(controller.value);
    contracts[contract.id] = contract;
    controller.add(contracts);

    return _insertOrUpdateContract(contract.toJson());
  }

  /// Delete a Contract from the database based on [id]
  Future<int> _deleteContract(String id) async {
    return _coreLocalStorage.delete(ContractTable.tableName, id);
  }

  /// Delete a Contract based on [id] and [done] status
  @override
  Future<int> deleteContract({required String id, required bool done}) async {
    late final BehaviorSubject<Map<String, Contract>> controller;

    if (done == false) {
      controller = _activeContractStreamController;
    } else {
      controller = _doneContractStreamController;
    }

    final contracts = Map<String, Contract>.from(controller.value)..remove(id);
    controller.add(contracts);

    return _deleteContract(id);
  }

  /// Close the both controllers
  @override
  Future<void> close() {
    _activeContractStreamController.close();
    return _doneContractStreamController.close();
  }
}
