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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  Future<List<Location>> getAllLocations() async {
    final db = await database;

    final maps = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnDeleted} = ?',
      whereArgs: [0],
    );

    return maps.map((map) => _locationFromMap(map)).toList();
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
      where:
          '${LocationTable.columnId} = ? AND ${LocationTable.columnDeleted} = ?',
      whereArgs: [location.id, 0],
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
      normalQuantity: map[LocationTable.columnNormalQuantity] as double?,
      oversizeQuantity: map[LocationTable.columnOversizeQuantity] as double?,
      pieceCount: map[LocationTable.columnPieceCount] as int,
      photoUrls: List<String>.from(
          jsonDecode(map[LocationTable.columnPhotoUrls] ?? '[]')),
      photoIds:
          List<int>.from(jsonDecode(map[LocationTable.columnPhotoIds] ?? '[]')),
    );
  }

  Future<int> insertShipment(Shipment shipment) async {
    final db = await database;

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

    return await db.insert(ShipmentTable.tableName, values);
  }

  Future<List<Shipment>> getAllShipments() async {
    final db = await database;
    final maps = await db.query(ShipmentTable.tableName,
        where: '${ShipmentTable.columnDeleted} = ?', whereArgs: [0]);
    return maps.map((map) => _shipmentFromMap(map)).toList();
  }

  Future<List<Shipment>> getShipmentsByLocation(int locationId) async {
    final db = await database;

    final maps = await db.query(
      ShipmentTable.tableName,
      where:
          '${ShipmentTable.columnLocationId} = ? AND ${ShipmentTable.columnDeleted} = ?',
      whereArgs: [locationId, 0],
      orderBy: '${ShipmentTable.columnDate} DESC',
    );

    return maps.map((map) => _shipmentFromMap(map)).toList();
  }

  Future<bool> deleteShipmentsByLocation(int locationId) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      ShipmentTable.tableName,
      where:
          '${ShipmentTable.columnLocationId} = ? AND ${ShipmentTable.columnDeleted} = ?',
      whereArgs: [locationId, 0],
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

    final List<Map<String, dynamic>> result = await db.query(
      ShipmentTable.tableName,
      where:
          '${ShipmentTable.columnId} = ? AND ${ShipmentTable.columnDeleted} = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (result.isNotEmpty) {
      await db.update(
        ShipmentTable.tableName,
        {
          ShipmentTable.columnDeleted: 1,
          ShipmentTable.columnDate: DateTime.now().millisecondsSinceEpoch
        },
        where: '${ShipmentTable.columnId} = ?',
        whereArgs: [id],
      );
      return true;
    }

    return false;
  }

  Shipment _shipmentFromMap(Map<String, dynamic> map) {
    return Shipment(
      id: map[ShipmentTable.columnId] as int,
      userId: map[ShipmentTable.columnUserId] as String,
      locationId: map[ShipmentTable.columnLocationId] as int,
      date: DateTime.fromMillisecondsSinceEpoch(
          map[ShipmentTable.columnDate] as int),
      deleted: map[ShipmentTable.columnDeleted] as int,
      contract: map[ShipmentTable.columnContract] as String?,
      additionalInfo: map[ShipmentTable.columnAdditionalInfo] as String?,
      sawmill: map[ShipmentTable.columnSawmill] as String,
      normalQuantity: map[ShipmentTable.columnNormalQuantity] as double?,
      oversizeQuantity: map[ShipmentTable.columnOversizeQuantity] as double?,
      pieceCount: map[ShipmentTable.columnPieceCount] as int,
    );
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

  Future<void> debugRestoreValues() async {
    final db = await database;

    await db.update(
      LocationTable.tableName,
      {LocationTable.columnDeleted: 0}
    );

    await db.update(
      ShipmentTable.tableName,
      {ShipmentTable.columnDeleted: 0}
    );
  }
}
