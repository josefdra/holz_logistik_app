import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/database/tables.dart';

const int locationIds = 0;
const int contractIds = 1;
const int quantityIds = 2;

class EntityHandler<T> {
  final String tableName;
  final String idColumn;
  final String lastEditedColumn;
  final String? doneColumn;
  final String? deletedColumn;
  final Future<T> Function(Map<String, dynamic> values) fromMap;
  final Future<Map<String, dynamic>> Function(T entity)?
      getCreateValuesFromEntity;
  final Future<Map<String, dynamic>> Function(T entity)?
      getUpdateValuesFromEntity;
  final int Function(T entity)? getIdFromEntity;
  final Database Function() getDatabaseInstance;

  EntityHandler({
    required this.tableName,
    required this.idColumn,
    required this.lastEditedColumn,
    this.doneColumn,
    this.deletedColumn,
    required this.fromMap,
    this.getCreateValuesFromEntity,
    this.getUpdateValuesFromEntity,
    this.getIdFromEntity,
    required this.getDatabaseInstance,
  });

  Future<List<Map<String, dynamic>>> getDataSinceLastSync(int lastSync) async {
    final db = getDatabaseInstance();

    return await db.query(
      tableName,
      where: '$lastEditedColumn > ?',
      whereArgs: [lastSync],
    );
  }

  Future<int> create(dynamic entityOrValues) async {
    final db = getDatabaseInstance();
    Map<String, dynamic> values;

    if (entityOrValues is T && getCreateValuesFromEntity != null) {
      values = await getCreateValuesFromEntity!(entityOrValues);
    } else if (entityOrValues is Map<String, dynamic>) {
      values = entityOrValues;
    } else {
      throw ArgumentError('Parameter must be $T or Map<String, dynamic>');
    }

    return await db.insert(tableName, values);
  }

  Future<T> getById(int id) async {
    final db = getDatabaseInstance();

    List<Map<String, dynamic>> values = await db.query(
      tableName,
      where: '$idColumn = ?',
      whereArgs: [id],
    );

    return fromMap(values.first);
  }

  Future<int> update(dynamic entityOrValues) async {
    final db = getDatabaseInstance();
    final int id;
    Map<String, dynamic> values;

    if (entityOrValues is T &&
        getUpdateValuesFromEntity != null &&
        getIdFromEntity != null) {
      values = await getUpdateValuesFromEntity!(entityOrValues);
      id = getIdFromEntity!(entityOrValues);
    } else if (entityOrValues is Map<String, dynamic>) {
      values = Map<String, dynamic>.from(entityOrValues);
      id = values[idColumn];
    } else {
      throw ArgumentError('Parameter must be $T or Map<String, dynamic>');
    }

    return await db.update(
      tableName,
      values,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  int _extractId(dynamic entityId) {
    if (entityId is int) {
      return entityId;
    } else if (entityId is T && getIdFromEntity != null) {
      return getIdFromEntity!(entityId);
    } else if (entityId is Map<String, dynamic>) {
      return entityId[idColumn];
    } else {
      throw ArgumentError('Parameter must be int, $T, or Map<String, dynamic>');
    }
  }

  Future<int> _updateStatus(String? columnName, dynamic entityId) async {
    if (columnName == null) {
      throw ArgumentError('Column not defined for $tableName');
    }

    final db = getDatabaseInstance();
    final id = _extractId(entityId);

    return await db.update(
      tableName,
      {
        columnName: 1,
        'lastEdited': DateTime.now().millisecondsSinceEpoch,
      },
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<int> finish(dynamic entityId) async {
    return _updateStatus(doneColumn, entityId);
  }

  Future<int> delete(dynamic entityId) async {
    return _updateStatus(deletedColumn, entityId);
  }

  Future<int> sync(Map<String, dynamic> values) async {
    final db = getDatabaseInstance();
    final id = values[idColumn];

    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: [idColumn],
      where: '$idColumn = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return await update(values);
    } else {
      return await create(values);
    }
  }
}

class DatabaseHelper {
  static const _databaseName = "holz_logistik.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  EntityHandler<Quantity> get quantityHandler => EntityHandler<Quantity>(
        tableName: QuantityTable.tableName,
        idColumn: QuantityTable.columnId,
        lastEditedColumn: QuantityTable.columnLastEdited,
        deletedColumn: QuantityTable.columnDeleted,
        fromMap: (values) async => Quantity.fromMap(values),
        getCreateValuesFromEntity: (entity) async =>
            Quantity.getCreateValues(entity),
        getUpdateValuesFromEntity: (entity) async =>
            Quantity.getUpdateValues(entity),
        getIdFromEntity: (entity) => entity.id,
        getDatabaseInstance: () => _getDb(),
      );

  EntityHandler<Location> get locationHandler => EntityHandler<Location>(
        tableName: LocationTable.tableName,
        idColumn: LocationTable.columnId,
        lastEditedColumn: LocationTable.columnLastEdited,
        deletedColumn: LocationTable.columnDeleted,
        doneColumn: LocationTable.columnDone,
        fromMap: (values) async => Location.fromMap(
            values, contract, initialQuantity, currentQuantity),
        getCreateValuesFromEntity: (entity) async =>
            await Location.getCreateValues(entity),
        getUpdateValuesFromEntity: (entity) async =>
            await Location.getUpdateValues(entity),
        getIdFromEntity: (entity) => entity.id,
        getDatabaseInstance: () => _getDb(),
      );

  EntityHandler<Shipment> get shipmentHandler => EntityHandler<Shipment>(
        tableName: ShipmentTable.tableName,
        idColumn: ShipmentTable.columnId,
        lastEditedColumn: ShipmentTable.columnLastEdited,
        deletedColumn: ShipmentTable.columnDeleted,
        getCreateValuesFromEntity: (entity) async =>
            await Shipment.getCreateValues(entity),
        getUpdateValuesFromEntity: (entity) async =>
            await Shipment.getValues(entity),
        getIdFromEntity: (entity) => entity.id,
        getDatabaseInstance: () => _getDb(),
      );

  EntityHandler<Contract> get contractHandler => EntityHandler<Contract>(
        tableName: ContractTable.tableName,
        idColumn: ContractTable.columnId,
        lastEditedColumn: ContractTable.columnLastEdited,
        deletedColumn: ContractTable.columnDeleted,
        doneColumn: ContractTable.columnDone,
        getCreateValuesFromEntity: (entity) async =>
            await Contract.getCreateValues(entity),
        getUpdateValuesFromEntity: (entity) async =>
            await Contract.getUpdateValues(entity),
        getIdFromEntity: (entity) => entity.id,
        getDatabaseInstance: () => _getDb(),
      );

  EntityHandler<User> get userHandler => EntityHandler<User>(
        tableName: UserTable.tableName,
        idColumn: UserTable.columnId,
        lastEditedColumn: UserTable.columnLastEdited,
        getDatabaseInstance: () => _getDb(),
      );

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
    await db.execute(QuantityTable.createTable);
    await db.execute(LocationTable.createTable);
    await db.execute(ShipmentTable.createTable);
    await db.execute(ContractTable.createTable);
    await db.execute(UserTable.createTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    //
  }

  Database _getDb() {
    if (_database == null) {
      throw StateError("Database not initialized");
    }
    return _database!;
  }

  Future<void> updateDB(String userId) async {
    final db = await database;

    await db.update(
      LocationTable.tableName,
      {LocationTable.columnUserId: userId},
      where: '${LocationTable.columnUserId} = ?',
      whereArgs: [""],
    );

    await db.update(
      ShipmentTable.tableName,
      {ShipmentTable.columnUserId: userId},
      where: '${ShipmentTable.columnUserId} = ?',
      whereArgs: [""],
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> getUnSyncedChanges(
      int lastSync) async {
    final quantityMaps = await quantityHandler.getDataSinceLastSync(lastSync);
    final locationMaps = await locationHandler.getDataSinceLastSync(lastSync);
    final shipmentMaps = await shipmentHandler.getDataSinceLastSync(lastSync);
    final contractMaps = await contractHandler.getDataSinceLastSync(lastSync);

    return {
      'quantities': quantityMaps,
      'locations': locationMaps,
      'shipments': shipmentMaps,
      'contracts': contractMaps
    };
  }

  /// --------------------------------------- Quantity --------------------------------------- ///

  Future<Map<int, Quantity>> _batchLoadQuantities(List<int> quantityIds) async {
    if (quantityIds.isEmpty) return {};

    final db = await database;
    final placeholders = List.filled(quantityIds.length, '?').join(',');

    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT q.*
      FROM ${QuantityTable.tableName} q
      WHERE q.${QuantityTable.columnId} IN ($placeholders)
    ''', quantityIds);

    final Map<int, Quantity> quantityMap = {};
    for (final row in result) {
      final id = row[QuantityTable.columnId] as int;
      quantityMap[id] = Quantity.fromMap(row);
    }

    return quantityMap;
  }

  /// --------------------------------------- Location --------------------------------------- ///

  Future<List<Map<String, dynamic>>> _getLocationsWithFilteredQuery(
      {bool? done, bool? deleted, bool hasShipments = false}) async {
    final db = await database;

    final List<String> whereConditions = [];

    if (done != null) {
      whereConditions.add('l.${LocationTable.columnDone} = ${done ? 1 : 0}');
    }

    if (deleted != null) {
      whereConditions
          .add('l.${LocationTable.columnDeleted} = ${deleted ? 1 : 0}');
    }

    if (hasShipments) {
      whereConditions.add('''
        EXISTS (
          SELECT 1 
          FROM ${ShipmentTable.tableName} s 
          WHERE s.${ShipmentTable.columnLocationId} = l.${LocationTable.columnId}
            AND s.${ShipmentTable.columnDeleted} = 0
        )
      ''');
    }

    final whereClause = whereConditions.isNotEmpty
        ? 'WHERE ${whereConditions.join(' AND ')}'
        : '';

    return db.rawQuery('''
      SELECT DISTINCT l.*
      FROM ${LocationTable.tableName} l
      $whereClause
    ''');
  }

  List<List<int>> _getIds(List<Map<String, dynamic>> locationMaps) {
    final List<List<int>> ids = [];

    final List<int> locationIds = locationMaps
        .map<int>((map) => map[LocationTable.columnId] as int)
        .toList();
    ids.add(locationIds);

    final List<int> contractIds = locationMaps
        .map<int>((map) => map[LocationTable.columnContractId] as int)
        .toList();
    ids.add(contractIds);

    final List<int> initialQuantityIds = locationMaps
        .map<int>((map) => map[LocationTable.columnInitialQuantityId] as int)
        .toList();

    final List<int> currentQuantityIds = locationMaps
        .map<int>((map) => map[LocationTable.columnCurrentQuantityId] as int)
        .toList();

    final List<int> allQuantityIds = [
      ...initialQuantityIds,
      ...currentQuantityIds
    ];
    ids.add(allQuantityIds);

    return ids;
  }

  Future<List<Location>?> batchLoadLocations(
      {bool? done, bool? deleted, bool includeShipments = false}) async {
    final List<Map<String, dynamic>> locationMaps =
        await _getLocationsWithFilteredQuery(
            done: done, deleted: deleted, hasShipments: includeShipments);

    if (locationMaps.isEmpty) {
      return null;
    }

    List<List<int>> ids = _getIds(locationMaps);

    final Map<int, Contract> contractsMap =
        await _batchLoadContracts(ids[contractIds]);

    final Map<int, Quantity> quantitiesMap =
        await _batchLoadQuantities(ids[quantityIds]);

    final List<Location> locations = locationMaps.map((map) {
      final int contractId = map[LocationTable.columnContractId];
      final int initialQuantityId = map[LocationTable.columnInitialQuantityId];
      final int currentQuantityId = map[LocationTable.columnCurrentQuantityId];

      return Location.fromMap(map, contractsMap[contractId]!,
          quantitiesMap[initialQuantityId]!, quantitiesMap[currentQuantityId]!);
    }).toList();

    return locations;
  }

  /// --------------------------------------- Shipment --------------------------------------- ///

  List<int> _getShipmentQuantityIds(List<Map<String, dynamic>> shipmentMaps) {
    final List<int> quantityIds = shipmentMaps
        .map<int>((map) => map[ShipmentTable.columnQuantityId] as int)
        .toList();

    return quantityIds;
  }

  Future<List<Shipment>> getShipmentsByLocationId(int locationId) async {
    final db = await database;

    List<Map<String, dynamic>> shipmentMaps = await db.rawQuery('''
      SELECT 
        s.*, u.*
      FROM ${ShipmentTable.tableName} s
      INNER JOIN ${UserTable.tableName} u ON u.${UserTable.columnId} = s.${ShipmentTable.columnUserId}
      WHERE s.${ShipmentTable.columnLocationId} = ? AND s.${ShipmentTable.columnDeleted} = 0
    ''', [locationId]);

    final List<int> quantityIds = _getShipmentQuantityIds(shipmentMaps);

    final Map<int, Quantity> quantitiesMap =
        await _batchLoadQuantities(quantityIds);

    final List<Shipment> shipments = shipmentMaps.map((map) {
      final int quantityId = map[ShipmentTable.columnQuantityId];

      return Shipment.fromMap(map, quantitiesMap[quantityId]!);
    }).toList();

    return shipments;
  }

  /// --------------------------------------- Contract --------------------------------------- ///

  Future<Map<int, Contract>> _batchLoadContracts(List<int> contractIds) async {
    if (contractIds.isEmpty) return {};

    final db = await database;
    final placeholders = List.filled(contractIds.length, '?').join(',');

    final result = await db.rawQuery('''
      SELECT c.*
      FROM ${ContractTable.tableName} c
      WHERE c.${ContractTable.columnId} IN ($placeholders)
    ''', contractIds);

    final Map<int, Contract> contractMap = {};
    for (final row in result) {
      final id = row[ContractTable.columnId] as int;
      contractMap[id] = Contract.fromMap(row);
    }

    return contractMap;
  }
}
