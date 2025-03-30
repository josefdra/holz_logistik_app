import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:holz_logistik/data/models.dart';
import 'package:holz_logistik/data/tables.dart';

class DatabaseHelper {
  static const _databaseName = "holz_logistik.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(UserTable.createTable);
    await db.execute(ContractTable.createTable);
    await db.execute(QuantityTable.createTable);
    await db.execute(ShipmentTable.createTable);
    await db.execute(LocationTable.createTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    //
  }

  Future<Map<String, dynamic>> getById(String tableName, int id) async {
    final db = await database;

    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.first;
  }

  Future<int> insert(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      tableName,
      data,
    );
  }

  Map<String, dynamic> getUpdateMap(Map<String, dynamic> map, {bool? done}) {
    final additionalFields = <String, dynamic>{
      'lastEdited': DateTime.now().millisecondsSinceEpoch,
    };

    if (done != null) {
      additionalFields[ContractTable.columnDone] = done ? 1 : 0;
    }

    map.addAll(additionalFields);

    return map;
  }

  Future<int> update(
      String tableName, Map<String, dynamic> data, String idColumn) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: '$idColumn = ?',
      whereArgs: [data[idColumn]],
    );
  }

  Future<int> delete(String tableName, String idColumn, int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertOrUpdate(
      String tableName, Map<String, dynamic> data, String idColumn) async {
    final db = await database;

    final List<Map<String, dynamic>> existing = await db.query(
      tableName,
      where: '$idColumn = ?',
      whereArgs: [data[idColumn]],
    );

    if (existing.isNotEmpty) {
      return await update(tableName, data, idColumn);
    }

    return await insert(tableName, data);
  }

  /// --------------------------------------- User --------------------------------------- ///

  Future<List<User>> _batchLoadUsersByIds(List<int> ids) async {
    final db = await database;

    final result = await db.query(
      UserTable.tableName,
      where:
          '${UserTable.columnId} IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: [...ids],
    );

    final List<User> users = [];
    for (final row in result) {
      users.add(User.fromMap(row));
    }

    return users;
  }

  Future<int> insertOrUpdateUser(Map<String, dynamic> userData) async {
    return await insertOrUpdate(
        UserTable.tableName, userData, UserTable.columnId);
  }

  Future<int> deleteUser(int id) async {
    return await delete(UserTable.tableName, UserTable.columnId, id);
  }

  /// --------------------------------------- Contract --------------------------------------- ///

  Future<List<Contract>> getActiveContracts() async {
    final db = await database;

    final result = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnDone} = ?',
      whereArgs: [0],
    );

    final List<Contract> contracts = [];
    for (final row in result) {
      contracts.add(Contract.fromMap(row));
    }

    return contracts;
  }

  Future<List<Contract>> getDoneContracts() async {
    final db = await database;

    final result = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnDone} = ?',
      whereArgs: [1],
    );

    final List<Contract> contracts = [];
    for (final row in result) {
      contracts.add(Contract.fromMap(row));
    }

    return contracts;
  }

  Future<List<Contract>> _batchLoadContractsByIds(List<int> ids) async {
    final db = await database;

    final result = await db.query(
      ContractTable.tableName,
      where:
          '${ContractTable.columnId} IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: [...ids],
    );

    final List<Contract> contracts = [];
    for (final row in result) {
      contracts.add(Contract.fromMap(row));
    }

    return contracts;
  }

  Future<int> insertOrUpdateContract(Map<String, dynamic> contractData) async {
    return await insertOrUpdate(
        ContractTable.tableName, contractData, ContractTable.columnId);
  }

  Future<int> deleteContract(int id) async {
    return await delete(ContractTable.tableName, ContractTable.columnId, id);
  }

  Future<bool> isContractUsed(int id) async {
    final db = await database;

    final locations = await db.query(LocationTable.tableName,
        where: '${LocationTable.columnContractId} = ?', whereArgs: [id]);

    if (locations.isNotEmpty) {
      return true;
    }

    final shipments = await db.query(ShipmentTable.tableName,
        where: '${ShipmentTable.columnContractId} = ?', whereArgs: [id]);

    if (shipments.isNotEmpty) {
      return true;
    }

    return false;
  }

  /// --------------------------------------- Quantity --------------------------------------- ///

  Future<List<Quantity>> _batchLoadQuantitiesByIds(List<int> ids) async {
    final db = await database;

    final result = await db.query(
      QuantityTable.tableName,
      where:
          '${QuantityTable.columnId} IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: [...ids],
    );

    final List<Quantity> quantities = [];
    for (final row in result) {
      quantities.add(Quantity.fromMap(row));
    }

    return quantities;
  }

  Future<int> insertOrUpdateQuantity(Map<String, dynamic> quantityData) async {
    return await insertOrUpdate(
        QuantityTable.tableName, quantityData, QuantityTable.columnId);
  }

  Future<int> deleteQuantity(int id) async {
    return await delete(QuantityTable.tableName, QuantityTable.columnId, id);
  }

  /// --------------------------------------- Shipment --------------------------------------- ///

  Future<List<Shipment>> _batchLoadShipmentsFromMap(
      List<Map<String, dynamic>> result) async {
    final List<int> quantityIds = result
        .map((map) => map[ShipmentTable.columnQuantityId] as int)
        .toList();
    final List<int> userIds =
        result.map((map) => map[ShipmentTable.columnUserId] as int).toList();
    final List<int> contractIds = result
        .map((map) => map[ShipmentTable.columnContractId] as int)
        .toList();

    final List<Quantity> quantities =
        await _batchLoadQuantitiesByIds(quantityIds);
    final List<User> users = await _batchLoadUsersByIds(userIds);
    final List<Contract> contracts =
        await _batchLoadContractsByIds(contractIds);

    final List<Shipment> shipments = [];
    for (int i = 0; i < result.length; i++) {
      final shipment = Shipment.fromMap(result[i]);
      shipment.quantity = quantities[i];
      shipment.user = users[i];
      shipment.contract = contracts[i];
      shipments.add(shipment);
    }

    return shipments;
  }

  Future<List<Shipment>> getShipments() async {
    final db = await database;

    final result = await db.query(
      ShipmentTable.tableName,
    );

    if (result.isEmpty) {
      return [];
    }

    final shipments = await _batchLoadShipmentsFromMap(result);

    return shipments;
  }

  Future<List<Shipment>> _batchLoadShipmentsByLocationId(int locationId) async {
    final db = await database;

    final result = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnLocationId} = ?',
      whereArgs: [locationId],
    );

    if (result.isEmpty) {
      return [];
    }

    final shipments = await _batchLoadShipmentsFromMap(result);

    return shipments;
  }

  Future<int> insertOrUpdateShipment(Map<String, dynamic> shipmentData) async {
    return await insertOrUpdate(
        ShipmentTable.tableName, shipmentData, ShipmentTable.columnId);
  }

  Future<int> deleteShipment(int id) async {
    return await delete(ShipmentTable.tableName, ShipmentTable.columnId, id);
  }

  /// --------------------------------------- Location --------------------------------------- ///

  Future<List<Location>> _batchLoadLocationsFromMap(
      List<Map<String, dynamic>> result) async {
    final List<int> contractIds = result
        .map((map) => map[LocationTable.columnContractId] as int)
        .toList();
    final List<int> initialQuantityIds = result
        .map((map) => map[LocationTable.columnInitialQuantityId] as int)
        .toList();
    final List<int> currentQuantityIds = result
        .map((map) => map[LocationTable.columnCurrentQuantityId] as int)
        .toList();

    final List<Contract> contracts =
        await _batchLoadContractsByIds(contractIds);
    final List<Quantity> initialQuantities =
        await _batchLoadQuantitiesByIds(initialQuantityIds);
    final List<Quantity> currentQuantities =
        await _batchLoadQuantitiesByIds(currentQuantityIds);

    final List<Location> locations = [];
    for (int i = 0; i < result.length; i++) {
      final location = Location.fromMap(result[i]);
      location.contract = contracts[i];
      location.initialQuantity = initialQuantities[i];
      location.currentQuantity = currentQuantities[i];
      location.shipments = await _batchLoadShipmentsByLocationId(location.id);

      locations.add(location);
    }

    return locations;
  }

  Future<List<Location>> getActiveLocations() async {
    final db = await database;

    final result = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnDone} = ?',
      whereArgs: [0],
    );

    if (result.isEmpty) {
      return [];
    }

    final locations = await _batchLoadLocationsFromMap(result);

    return locations;
  }

  Future<List<Location>> getDoneLocations() async {
    final db = await database;

    final result = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnDone} = ?',
      whereArgs: [1],
    );

    if (result.isEmpty) {
      return [];
    }

    final locations = await _batchLoadLocationsFromMap(result);

    return locations;
  }

  Future<int> insertOrUpdateLocation(Map<String, dynamic> locationData) async {
    return await insertOrUpdate(
        LocationTable.tableName, locationData, LocationTable.columnId);
  }

  Future<int> deleteLocation(int id) async {
    return await delete(LocationTable.tableName, LocationTable.columnId, id);
  }
}
