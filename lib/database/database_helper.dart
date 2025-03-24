import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/database/tables.dart';

const int locationIds = 0;
const int contractIds = 1;
const int quantityIds = 2;

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
    await db.execute(QuantityTable.createTable);
    await db.execute(LocationTable.createTable);
    await db.execute(ShipmentTable.createTable);
    await db.execute(ContractTable.createTable);
    await db.execute(UserTable.createTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    //
  }

  /// ----------------------------------------------- Quantity ----------------------------------------------- ///

  Future<Map<int, Quantity>> batchLoadQuantities(List<int> quantityIds) async {
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

  Future<Quantity> getQuantityById(int quantityId) async {
    final db = await database;

    List<Map<String, dynamic>> quantityMap = await db.rawQuery('''
      SELECT 
        q.*
      FROM ${QuantityTable.tableName} q
      WHERE q.${QuantityTable.columnId} = ?
    ''', [quantityId]);

    final Quantity quantity = Quantity.fromMap(quantityMap.first);

    return quantity;
  }

  /// ----------------------------------------------- Location ----------------------------------------------- ///

  Future<List<Map<String, dynamic>>> _getlocationsWithFilteredQuery(
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

  Future<DisplayLocation> _getDisplayLocation(
      Map<String, dynamic> locationMap, bool includeShipments) async {
    final locationId = locationMap[LocationTable.columnId];
    final DisplayContract contract =
        await getContractById(locationMap[LocationTable.columnContractId]);
    final Quantity initialQuantity = await getQuantityById(
        locationMap[LocationTable.columnInitialQuantityId]);
    final Quantity currentQuantity = await getQuantityById(
        locationMap[LocationTable.columnCurrentQuantityId]);
    final List<DisplayShipment>? shipments =
        includeShipments ? await getShipmentsByLocationId(locationId) : null;
    final location = DisplayLocation.fromMap(
        locationMap, contract, initialQuantity, currentQuantity,
        shipments: shipments);

    return location;
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

  Future<List<DisplayLocation>?> batchLoadLocations(
      {bool? done, bool? deleted, bool includeShipments = false}) async {
    final List<Map<String, dynamic>> locationMaps =
        await _getlocationsWithFilteredQuery(
            done: done, deleted: deleted, hasShipments: includeShipments);

    if (locationMaps.isEmpty) {
      return null;
    }

    List<List<int>> ids = _getIds(locationMaps);

    final Map<int, DisplayContract> contractsMap =
        await batchLoadContracts(ids[contractIds]);

    final Map<int, Quantity> quantitiesMap =
        await batchLoadQuantities(ids[quantityIds]);

    Map<int, List<DisplayShipment>> shipmentsByLocation = {};
    if (includeShipments) {
      shipmentsByLocation = await batchLoadShipmentsByLocationIds(ids[locationIds]);
    }

    final List<DisplayLocation> locations = locationMaps.map((map) {
      final int locationId = map[LocationTable.columnId];
      final int contractId = map[LocationTable.columnContractId];
      final int initialQuantityId = map[LocationTable.columnInitialQuantityId];
      final int currentQuantityId = map[LocationTable.columnCurrentQuantityId];

      return DisplayLocation.fromMap(map, contractsMap[contractId]!,
          quantitiesMap[initialQuantityId]!, quantitiesMap[currentQuantityId]!,
          shipments: includeShipments ? shipmentsByLocation[locationId] : null);
    }).toList();

    return locations;
  }

  Future<DisplayLocation?> getLocationById(
      int locationId, bool includeShipments) async {
    final db = await database;

    List<Map<String, dynamic>> locationMap = await db.rawQuery('''
      SELECT 
        l.*
      FROM ${LocationTable.tableName} l
      WHERE l.${LocationTable.columnId} = ?
    ''', [locationId]);

    return _getDisplayLocation(locationMap.first, includeShipments);
  }

  /// ----------------------------------------------- Shipment ----------------------------------------------- ///

  Future<Map<int, List<DisplayShipment>>> batchLoadShipmentsByLocationIds(
      List<int> locationIds) async {
    if (locationIds.isEmpty) return {};

    final db = await database;
    final placeholders = List.filled(locationIds.length, '?').join(',');

    final shipmentMaps = await db.rawQuery('''
      SELECT s.*
      FROM ${ShipmentTable.tableName} s
      WHERE s.${ShipmentTable.columnLocationId} IN ($placeholders)
        AND s.${ShipmentTable.columnDeleted} = 0
    ''', locationIds);

    final Map<int, List<Map<String, dynamic>>> shipmentsByLocation = {};
    for (final shipmentMap in shipmentMaps) {
      final locationId = shipmentMap[ShipmentTable.columnLocationId] as int;
      shipmentsByLocation.putIfAbsent(locationId, () => []).add(shipmentMap);
    }

    final List<int> quantityIds = [];
    for (final shipmentMap in shipmentMaps) {
      quantityIds.add(shipmentMap[ShipmentTable.columnQuantityId] as int);
    }

    Map<int, Quantity> quantities = await batchLoadQuantities(quantityIds);

    final Map<int, List<DisplayShipment>> shipments = {};
    shipmentsByLocation.forEach((locationId, shipmentMaps) {
      shipments[locationId] = shipmentMaps.map((map) {
        final quantityId = map[ShipmentTable.columnQuantityId] as int;
        final quantity = quantities[quantityId]!;
        return DisplayShipment.fromMap(map, quantity);
      }).toList();
    });

    return shipments;
  }

  Future<List<DisplayShipment>> getShipmentsByLocationId(int locationId) async {
    final db = await database;

    List<Map<String, dynamic>> shipmentMaps = await db.rawQuery('''
      SELECT 
        s.*
      FROM ${ShipmentTable.tableName} s
      WHERE s.${ShipmentTable.columnLocationId} = ?
    ''', [locationId]);

    final List<DisplayShipment> shipments = [];

    for (final shipmentMap in shipmentMaps) {
      final quantityId = shipmentMap[ShipmentTable.columnQuantityId];
      final Quantity quantity = await getQuantityById(quantityId);
      shipments.add(DisplayShipment.fromMap(shipmentMap, quantity));
    }

    return shipments;
  }

  /// ----------------------------------------------- Contract ----------------------------------------------- ///

  Future<Map<int, DisplayContract>> batchLoadContracts(
      List<int> contractIds) async {
    if (contractIds.isEmpty) return {};

    final db = await database;
    final placeholders = List.filled(contractIds.length, '?').join(',');

    final result = await db.rawQuery('''
      SELECT c.*
      FROM ${ContractTable.tableName} c
      WHERE c.${ContractTable.columnId} IN ($placeholders)
    ''', contractIds);

    final Map<int, DisplayContract> contractMap = {};
    for (final row in result) {
      final id = row[ContractTable.columnId] as int;
      contractMap[id] = DisplayContract.fromMap(row);
    }

    return contractMap;
  }

  Future<DisplayContract> getContractById(int contractId) async {
    final db = await database;

    List<Map<String, dynamic>> contractMap = await db.rawQuery('''
      SELECT 
        c.*
      FROM ${ContractTable.tableName} c
      WHERE c.${ContractTable.columnId} = ?
    ''', [contractId]);

    final DisplayContract contract = DisplayContract.fromMap(contractMap.first);

    return contract;
  }

  /// ----------------------------------------------- End ----------------------------------------------- ///

  Future<int> insertOrUpdateLocation(Location location) async {
    final db = await database;

    final values = {
      LocationTable.columnId: DateTime.now().microsecondsSinceEpoch,
      LocationTable.columnUserId: user,
      LocationTable.columnLastEdited: DateTime.now().millisecondsSinceEpoch,
      LocationTable.columnDeleted: location.deleted,
      LocationTable.columnLatitude: location.latitude,
      LocationTable.columnLongitude: location.longitude,
      LocationTable.columnPartieNr: location.partieNr,
      LocationTable.columnContract: location.contract,
      LocationTable.columnAdditionalInfo: location.additionalInfo,
      LocationTable.columnSawmill: location.sawmill,
      LocationTable.columnOversizeSawmill: location.oversizeSawmill,
      LocationTable.columnNormalQuantity: location.normalQuantity,
      LocationTable.columnOversizeQuantity: location.oversizeQuantity,
      LocationTable.columnPieceCount: location.pieceCount,
      LocationTable.columnPhotoIds: jsonEncode(location.photoIds ?? []),
      LocationTable.columnPhotoUrls: jsonEncode(location.photoUrls ?? []),
    };

    final List<Map<String, dynamic>> result = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnId} = ?',
      whereArgs: [location.id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return await db.update(
        LocationTable.tableName,
        values,
        where: '${LocationTable.columnId} = ?',
        whereArgs: [location.id],
      );
    } else {
      return await db.insert(LocationTable.tableName, values);
    }
  }

  Future<bool> deleteLocation(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      LocationTable.tableName,
      where:
          '${LocationTable.columnId} = ? AND ${LocationTable.columnDeleted} = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (result.isNotEmpty) {
      await db.update(
        LocationTable.tableName,
        {
          LocationTable.columnDeleted: 1,
          LocationTable.columnLastEdited: DateTime.now().millisecondsSinceEpoch
        },
        where: '${LocationTable.columnId} = ?',
        whereArgs: [id],
      );

      deleteShipmentsByLocation(id);

      return true;
    }

    return false;
  }

  Location _locationFromMap(Map<String, dynamic> map) {
    return Location(
      id: map[LocationTable.columnId] as int,
      userId: map[LocationTable.columnUserId] as String,
      lastEdited: DateTime.fromMillisecondsSinceEpoch(
          map[LocationTable.columnLastEdited] as int),
      deleted: map[LocationTable.columnDeleted] as int,
      latitude: map[LocationTable.columnLatitude] as double,
      longitude: map[LocationTable.columnLongitude] as double,
      partieNr: map[LocationTable.columnPartieNr] as String,
      contract: map[LocationTable.columnContract] as String?,
      additionalInfo: map[LocationTable.columnAdditionalInfo] as String?,
      sawmill: map[LocationTable.columnSawmill] as String?,
      oversizeSawmill: map[LocationTable.columnOversizeSawmill] as String?,
      normalQuantity: map[LocationTable.columnNormalQuantity] as double,
      oversizeQuantity: map[LocationTable.columnOversizeQuantity] as double,
      pieceCount: map[LocationTable.columnPieceCount] as int,
      photoUrls: List<String>.from(
          jsonDecode(map[LocationTable.columnPhotoUrls] ?? '[]')),
      photoIds:
          List<int>.from(jsonDecode(map[LocationTable.columnPhotoIds] ?? '[]')),
    );
  }

  Future<int> insertShipment(Shipment shipment, bool sync) async {
    final db = await database;

    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> existingShipment = await txn.query(
        ShipmentTable.tableName,
        where: '${ShipmentTable.columnId} = ?',
        whereArgs: [shipment.id],
        limit: 1,
      );

      if (existingShipment.isNotEmpty) {
        if (shipment.deleted == 1) {
          deleteShipment(shipment.id, sync);
        }
        return 0;
      }

      if (!sync) {
        final List<Map<String, dynamic>> locationResult = await txn.query(
          LocationTable.tableName,
          where: '${LocationTable.columnId} = ?',
          whereArgs: [shipment.locationId],
          limit: 1,
        );

        if (locationResult.isEmpty) {
          throw Exception('Location not found for ID: ${shipment.locationId}');
        }

        final location = _locationFromMap(locationResult.first);

        location.pieceCount -= shipment.pieceCount;
        location.normalQuantity -= shipment.normalQuantity;
        location.oversizeQuantity -= shipment.oversizeQuantity;

        await txn.update(
          LocationTable.tableName,
          {
            LocationTable.columnLastEdited:
                DateTime.now().millisecondsSinceEpoch,
            LocationTable.columnPieceCount: location.pieceCount,
            LocationTable.columnNormalQuantity: location.normalQuantity,
            LocationTable.columnOversizeQuantity: location.oversizeQuantity,
          },
          where: '${LocationTable.columnId} = ?',
          whereArgs: [location.id],
        );
      }

      final values = {
        ShipmentTable.columnId: shipment.id,
        ShipmentTable.columnUserId: shipment.userId,
        ShipmentTable.columnLocationId: shipment.locationId,
        ShipmentTable.columnDate: shipment.date.millisecondsSinceEpoch,
        ShipmentTable.columnDeleted: shipment.deleted,
        ShipmentTable.columnContractId: shipment.contractId,
        ShipmentTable.columnSawmill: shipment.sawmill,
        ShipmentTable.columnNormalQuantity: shipment.normalQuantity,
        ShipmentTable.columnOversizeQuantity: shipment.oversizeQuantity,
        ShipmentTable.columnPieceCount: shipment.pieceCount,
      };

      return await txn.insert(ShipmentTable.tableName, values);
    });
  }

  Future<bool> deleteShipmentsByLocation(int locationId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnLocationId} = ?',
      whereArgs: [locationId],
    );

    if (result.isNotEmpty) {
      await db.update(
        ShipmentTable.tableName,
        {
          ShipmentTable.columnDeleted: 1,
          ShipmentTable.columnDate: DateTime.now().millisecondsSinceEpoch
        },
        where: '${ShipmentTable.columnLocationId} = ?',
        whereArgs: [locationId],
      );
      return true;
    }

    return false;
  }

  Future<bool> deleteShipment(int id, bool sync) async {
    final db = await database;

    return await db.transaction((txn) async {
      final shipmentResult = await txn.rawQuery('''
        SELECT 
          ${ShipmentTable.tableName}.*,
          ${UserTable.tableName}.${UserTable.columnName} AS name,
          ${ContractTable.tableName}.${ContractTable.columnName} AS contractName
        FROM ${ShipmentTable.tableName}
        LEFT JOIN ${UserTable.tableName}
          ON ${ShipmentTable.tableName}.${ShipmentTable.columnUserId} = ${UserTable.tableName}.${UserTable.columnId}
        LEFT JOIN ${ContractTable.tableName}
          ON ${ShipmentTable.tableName}.${ShipmentTable.columnContractId} = ${ContractTable.tableName}.${ContractTable.columnId}
        WHERE ${ShipmentTable.tableName}.${ShipmentTable.columnId} = ?
        LIMIT 1
      ''', [id]);

      if (shipmentResult.isEmpty) {
        return false;
      }

      final shipment = _shipmentFromMap(shipmentResult.first);

      if (shipment.deleted == 1) {
        return true;
      }

      if (!sync) {
        final List<Map<String, dynamic>> locationResult = await txn.query(
          LocationTable.tableName,
          where: '${LocationTable.columnId} = ?',
          whereArgs: [shipment.locationId],
          limit: 1,
        );

        if (locationResult.isEmpty) {
          throw Exception('Location not found for ID: ${shipment.locationId}');
        }

        final location = _locationFromMap(locationResult.first);

        location.pieceCount += shipment.pieceCount;
        location.normalQuantity += shipment.normalQuantity;
        location.oversizeQuantity += shipment.oversizeQuantity;

        await txn.update(
          LocationTable.tableName,
          {
            LocationTable.columnLastEdited:
                DateTime.now().millisecondsSinceEpoch,
            LocationTable.columnPieceCount: location.pieceCount,
            LocationTable.columnNormalQuantity: location.normalQuantity,
            LocationTable.columnOversizeQuantity: location.oversizeQuantity,
          },
          where: '${LocationTable.columnId} = ?',
          whereArgs: [location.id],
        );
      }

      await txn.update(
        ShipmentTable.tableName,
        {
          ShipmentTable.columnDeleted: 1,
          ShipmentTable.columnDate: DateTime.now().millisecondsSinceEpoch
        },
        where: '${ShipmentTable.columnId} = ?',
        whereArgs: [id],
      );

      return true;
    });
  }

  Shipment _shipmentFromMap(Map<String, dynamic> map) {
    return Shipment(
      id: map[ShipmentTable.columnId] as int,
      userId: map[ShipmentTable.columnUserId] as String,
      locationId: map[ShipmentTable.columnLocationId] as int,
      date: DateTime.fromMillisecondsSinceEpoch(
          map[ShipmentTable.columnDate] as int),
      name: map['name'] as String,
      contractName: map['contractName'] as String,
      deleted: map[ShipmentTable.columnDeleted] as int,
      contractId: map[ShipmentTable.columnContractId] as int,
      sawmill: map[ShipmentTable.columnSawmill] as String,
      normalQuantity: map[ShipmentTable.columnNormalQuantity] as double,
      oversizeQuantity: map[ShipmentTable.columnOversizeQuantity] as double,
      pieceCount: map[ShipmentTable.columnPieceCount] as int,
    );
  }

  Future<Contract?> getContractById(int id) async {
    final db = await database;
    final maps = await db.query(
      ContractTable.tableName,
      where:
          '${ContractTable.columnId} = ? AND ${ContractTable.columnDeleted} = ?',
      whereArgs: [id, 0],
    );

    if (maps.isEmpty) return null;
    return _contractFromMap(maps.first);
  }

  Future<List<Contract>> getAllContracts() async {
    final db = await database;
    final maps = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnDeleted} = ?',
      whereArgs: [0],
    );

    return maps.map((map) => _contractFromMap(map)).toList();
  }

  Future<int> insertOrUpdateContract(Contract contract) async {
    final db = await database;

    final values = {
      ContractTable.columnId: contract.id,
      ContractTable.columnLastEdited:
          contract.lastEdited.millisecondsSinceEpoch,
      ContractTable.columnDeleted: contract.deleted,
      ContractTable.columnName: contract.name,
      ContractTable.columnPrice: contract.price,
      ContractTable.columnTime: contract.time,
      ContractTable.columnAvailableQuantity: contract.availableQuantity,
      ContractTable.columnBookedQuantity: contract.bookedQuantity,
      ContractTable.columnShippedQuantity: contract.shippedQuantity,
    };

    final List<Map<String, dynamic>> result = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnId} = ?',
      whereArgs: [contract.id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return await db.update(
        ContractTable.tableName,
        values,
        where: '${ContractTable.columnId} = ?',
        whereArgs: [contract.id],
      );
    } else {
      return await db.insert(ContractTable.tableName, values);
    }
  }

  Contract _contractFromMap(Map<String, dynamic> map) {
    return Contract(
      id: map[ContractTable.columnId] as int,
      lastEdited: DateTime.fromMillisecondsSinceEpoch(
          map[ContractTable.columnLastEdited] as int),
      deleted: map[ContractTable.columnDeleted] as int,
      name: map[ContractTable.columnName] as String,
      price: map[ContractTable.columnPrice] as String,
      time: map[ContractTable.columnTime] as String,
      availableQuantity: map[ContractTable.columnAvailableQuantity] as int,
      bookedQuantity: map[ContractTable.columnBookedQuantity] as int,
      shippedQuantity: map[ContractTable.columnShippedQuantity] as int,
    );
  }

  Future<String> getUserNameById(int userId) async {
    final db = await database;

    final maps = await db.query(
      UserTable.tableName,
      where: '${UserTable.columnId} = ?',
      whereArgs: [userId],
    );

    return maps.first[UserTable.columnName] as String;
  }

  Future<int> insertOrUpdateUser(User user) async {
    final db = await database;

    final values = {
      UserTable.columnId: user.id,
      UserTable.columnName: user.name,
    };

    final List<Map<String, dynamic>> result = await db.query(
      UserTable.tableName,
      where: '${UserTable.columnId} = ?',
      whereArgs: [user.id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return await db.update(
        UserTable.tableName,
        values,
        where: '${UserTable.columnId} = ?',
        whereArgs: [user.id],
      );
    } else {
      return await db.insert(UserTable.tableName, values);
    }
  }

  Future<void> updateDB(String apiKey) async {
    final db = await database;

    await db.update(
      LocationTable.tableName,
      {LocationTable.columnUserId: apiKey},
      where: '${LocationTable.columnUserId} = ?',
      whereArgs: [""],
    );

    await db.update(
      ShipmentTable.tableName,
      {ShipmentTable.columnUserId: apiKey},
      where: '${ShipmentTable.columnUserId} = ?',
      whereArgs: [""],
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> getUnSyncedChanges(
      int lastSync) async {
    final db = await database;

    final locationMaps = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnLastEdited} > ?',
      whereArgs: [lastSync],
    );

    final shipmentMaps = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnDate} > ?',
      whereArgs: [lastSync],
    );

    final contractMaps = await db.query(
      ContractTable.tableName,
      where: '${ContractTable.columnLastEdited} > ?',
      whereArgs: [lastSync],
    );

    return {
      'locations': locationMaps,
      'shipments': shipmentMaps,
      'contracts': contractMaps,
    };
  }

  Future<void> printDatabaseContents() async {
    final db = await DatabaseHelper.instance.database;

    final shipments = await db.query(ShipmentTable.tableName);

    print('=================== SHIPMENTS TABLE ===================');
    print('Total shipments found: ${shipments.length}');

    for (var shipment in shipments) {
      print('-----------------------------------------------');
      print('ID: ${shipment[ShipmentTable.columnId]}');
      print('UserID: ${shipment[ShipmentTable.columnUserId]}');
      print('LocationID: ${shipment[ShipmentTable.columnLocationId]}');
      print(
          'Date: ${DateTime.fromMillisecondsSinceEpoch(shipment[ShipmentTable.columnDate] as int)}');
      print('Deleted: ${shipment[ShipmentTable.columnDeleted]}');
      print('ContractID: ${shipment[ShipmentTable.columnContractId]}');
      print('Sawmill: ${shipment[ShipmentTable.columnSawmill]}');
      print('NormalQuantity: ${shipment[ShipmentTable.columnNormalQuantity]}');
      print(
          'OversizeQuantity: ${shipment[ShipmentTable.columnOversizeQuantity]}');
      print('PieceCount: ${shipment[ShipmentTable.columnPieceCount]}');
    }
    print('=================== END SHIPMENTS ===================\n');

    final locations = await db.query(LocationTable.tableName);

    print('=================== LOCATIONS TABLE ===================');
    print('Total locations found: ${locations.length}');

    for (var location in locations) {
      print('-----------------------------------------------');
      print('ID: ${location[LocationTable.columnId]}');
      print('UserID: ${location[LocationTable.columnUserId]}');
      print(
          'LastEdited: ${DateTime.fromMillisecondsSinceEpoch(location[LocationTable.columnLastEdited] as int)}');
      print('Deleted: ${location[LocationTable.columnDeleted]}');
      print('Latitude: ${location[LocationTable.columnLatitude]}');
      print('Longitude: ${location[LocationTable.columnLongitude]}');
      print('PartieNr: ${location[LocationTable.columnPartieNr]}');
      print('Contract: ${location[LocationTable.columnContract]}');
      print('AdditionalInfo: ${location[LocationTable.columnAdditionalInfo]}');
      print('Sawmill: ${location[LocationTable.columnSawmill]}');
      print(
          'OversizeSawmill: ${location[LocationTable.columnOversizeSawmill]}');
      print('NormalQuantity: ${location[LocationTable.columnNormalQuantity]}');
      print(
          'OversizeQuantity: ${location[LocationTable.columnOversizeQuantity]}');
      print('PieceCount: ${location[LocationTable.columnPieceCount]}');
      print('PhotoIds: ${location[LocationTable.columnPhotoIds]}');
      print('PhotoUrls: ${location[LocationTable.columnPhotoUrls]}');
    }
    print('=================== END LOCATIONS ===================\n');

    final contracts = await db.query(ContractTable.tableName);

    print('=================== CONTRACTS TABLE ===================');
    print('Total contracts found: ${contracts.length}');

    for (var contract in contracts) {
      print('-----------------------------------------------');
      print('ID: ${contract[ContractTable.columnId]}');
      print(
          'LastEdited: ${DateTime.fromMillisecondsSinceEpoch(contract[ContractTable.columnLastEdited] as int)}');
      print('Deleted: ${contract[ContractTable.columnDeleted]}');
      print('Name: ${contract[ContractTable.columnName]}');
      print('Price: ${contract[ContractTable.columnPrice]}');
      print('Time: ${contract[ContractTable.columnTime]}');
      print(
          'AvailableQuantity: ${contract[ContractTable.columnAvailableQuantity]}');
      print('BookedQuantity: ${contract[ContractTable.columnBookedQuantity]}');
      print(
          'ShippedQuantity: ${contract[ContractTable.columnShippedQuantity]}');
    }
    print('=================== END CONTRACTS ===================');
  }
}
