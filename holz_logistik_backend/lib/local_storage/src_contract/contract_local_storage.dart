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
  late final _contractStreamController = BehaviorSubject<List<Contract>>.seeded(
    const [],
  );

  /// Migration function for contract table
  Future<void> _migrateContractTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Initialization
  Future<void> _init() async {
    final contractsJson =
        await _coreLocalStorage.getAll(ContractTable.tableName);
    final contracts = contractsJson
        .map(
          (contract) => Contract.fromJson(Map<String, dynamic>.from(contract)),
        )
        .toList();
    _contractStreamController.add(contracts);
  }

  /// Get the `contract`s from the [_contractStreamController]
  @override
  Stream<List<Contract>> get contracts =>
      _contractStreamController.asBroadcastStream();

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
    final contracts = [..._contractStreamController.value];
    final contractIndex = contracts.indexWhere((c) => c.id == contract.id);
    if (contractIndex >= 0) {
      contracts[contractIndex] = contract;
    } else {
      contracts.add(contract);
    }

    _contractStreamController.add(contracts);
    return _insertOrUpdateContract(contract.toJson());
  }

  /// Delete a Contract from the database based on [id]
  Future<int> _deleteContract(String id) async {
    return _coreLocalStorage.delete(ContractTable.tableName, id);
  }

  /// Delete a Contract based on [id]
  @override
  Future<int> deleteContract(String id) async {
    final contracts = [..._contractStreamController.value];
    final contractIndex = contracts.indexWhere((c) => c.id == id);
    if (contractIndex == -1) {
      throw ContractNotFoundException();
    } else {
      contracts.removeAt(contractIndex);
      _contractStreamController.add(contracts);
      return _deleteContract(id);
    }
  }

  /// Close the [_contractStreamController]
  @override
  Future<void> close() {
    return _contractStreamController.close();
  }
}
