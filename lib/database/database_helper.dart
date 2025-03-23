import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/database/tables.dart';

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
    await db.execute(LocationTable.createTable);
    await db.execute(ShipmentTable.createTable);
    await db.execute(UserTable.createTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  Future<List<Location>> getActiveLocations() async {
    final db = await database;

    final maps = await db.query(
      LocationTable.tableName,
      where:
          '${LocationTable.columnDeleted} = ? AND ${LocationTable.columnPieceCount} > 0',
      whereArgs: [0],
    );

    return maps.map((map) => _locationFromMap(map)).toList();
  }

  Future<List<Map<Location, List<Shipment>>>>
      getArchivedLocationsWithShipments() async {
    final db = await database;
    final result = <Map<Location, List<Shipment>>>[];

    final locationMaps = await db.rawQuery('''
      SELECT DISTINCT l.* 
      FROM ${LocationTable.tableName} l
      INNER JOIN ${ShipmentTable.tableName} s ON l.${LocationTable.columnId} = s.${ShipmentTable.columnLocationId}
      WHERE l.${LocationTable.columnDeleted} = ?
    ''', [0]);

    final locations = locationMaps.map((map) => _locationFromMap(map)).toList();

    for (final location in locations) {
      final shipmentMaps = await db.rawQuery('''
        SELECT 
          ${ShipmentTable.tableName}.*, 
          ${UserTable.tableName}.${UserTable.columnName} AS name
        FROM ${ShipmentTable.tableName}
        LEFT JOIN ${UserTable.tableName} 
          ON ${ShipmentTable.tableName}.${ShipmentTable.columnUserId} = ${UserTable.tableName}.${UserTable.columnId}
        WHERE ${ShipmentTable.tableName}.${ShipmentTable.columnLocationId} = ? 
          AND ${ShipmentTable.tableName}.${ShipmentTable.columnDeleted} = ?
        ORDER BY ${ShipmentTable.tableName}.${ShipmentTable.columnDate} DESC
      ''', [location.id, 0]);

      final shipments =
          shipmentMaps.map((map) => _shipmentFromMap(map)).toList();

      result.add({location: shipments});
    }

    return result;
  }

  Future<int> insertOrUpdateLocation(Location location) async {
    final db = await database;

    final values = {
      LocationTable.columnId: location.id,
      LocationTable.columnUserId: location.userId,
      LocationTable.columnLastEdited:
          location.lastEdited.millisecondsSinceEpoch,
      LocationTable.columnDeleted: location.deleted,
      LocationTable.columnLatitude: location.latitude,
      LocationTable.columnLongitude: location.longitude,
      LocationTable.columnPartieNr: location.partieNr,
      LocationTable.columnContract: location.contract,
      LocationTable.columnAdditionalInfo: location.additionalInfo,
      LocationTable.columnAccess: location.access,
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
      access: map[LocationTable.columnAccess] as String?,
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

  Future<int> insertShipment(Shipment shipment) async {
    final db = await database;

    return await db.transaction((txn) async {
      final List<Map<String, dynamic>> existingShipment = await txn.query(
        ShipmentTable.tableName,
        where: '${ShipmentTable.columnId} = ?',
        whereArgs: [shipment.id],
        limit: 1,
      );

      if (existingShipment.isNotEmpty) {
        return shipment.id;
      }

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
          LocationTable.columnLastEdited: DateTime.now().millisecondsSinceEpoch,
          LocationTable.columnPieceCount: location.pieceCount,
          LocationTable.columnNormalQuantity: location.normalQuantity,
          LocationTable.columnOversizeQuantity: location.oversizeQuantity,
        },
        where: '${LocationTable.columnId} = ?',
        whereArgs: [location.id],
      );

      final values = {
        ShipmentTable.columnId: shipment.id,
        ShipmentTable.columnUserId: shipment.userId,
        ShipmentTable.columnLocationId: shipment.locationId,
        ShipmentTable.columnDate: shipment.date.millisecondsSinceEpoch,
        ShipmentTable.columnDeleted: shipment.deleted,
        ShipmentTable.columnContract: shipment.contract,
        ShipmentTable.columnAdditionalInfo: shipment.additionalInfo,
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

  Future<bool> deleteShipment(int id) async {
    final db = await database;

    return await db.transaction((txn) async {
      final shipmentResult = await txn.rawQuery('''
        SELECT 
          ${ShipmentTable.tableName}.*, 
          ${UserTable.tableName}.${UserTable.columnName} AS name
        FROM ${ShipmentTable.tableName}
        LEFT JOIN ${UserTable.tableName} 
          ON ${ShipmentTable.tableName}.${ShipmentTable.columnUserId} = ${UserTable.tableName}.${UserTable.columnId}
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
          LocationTable.columnLastEdited: DateTime.now().millisecondsSinceEpoch,
          LocationTable.columnPieceCount: location.pieceCount,
          LocationTable.columnNormalQuantity: location.normalQuantity,
          LocationTable.columnOversizeQuantity: location.oversizeQuantity,
        },
        where: '${LocationTable.columnId} = ?',
        whereArgs: [location.id],
      );

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
      deleted: map[ShipmentTable.columnDeleted] as int,
      contract: map[ShipmentTable.columnContract] as String?,
      additionalInfo: map[ShipmentTable.columnAdditionalInfo] as String?,
      sawmill: map[ShipmentTable.columnSawmill] as String,
      normalQuantity: map[ShipmentTable.columnNormalQuantity] as double,
      oversizeQuantity: map[ShipmentTable.columnOversizeQuantity] as double,
      pieceCount: map[ShipmentTable.columnPieceCount] as int,
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

    return {
      'locations': locationMaps,
      'shipments': shipmentMaps,
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
      print('Contract: ${shipment[ShipmentTable.columnContract]}');
      print('AdditionalInfo: ${shipment[ShipmentTable.columnAdditionalInfo]}');
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
      print('Access: ${location[LocationTable.columnAccess]}');
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
    print('=================== END LOCATIONS ===================');
  }
}
