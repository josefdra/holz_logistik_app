import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/location.dart';
import '../models/shipment.dart';
import 'tables/location_table.dart';
import 'tables/shipment_table.dart';

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

  Future<void> printAllLocations() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(LocationTable.tableName);

      if (maps.isEmpty) {
        print('No locations found in database');
        return;
      }

      print('Found ${maps.length} locations:');
      for (var location in maps) {
        print('-----------------------------------');
        print('ID: ${location[LocationTable.columnId]}');
        print('User ID: ${location[LocationTable.columnUserId]}');
        print('Last Edited: ${DateTime.fromMillisecondsSinceEpoch(location[LocationTable.columnLastEdited])}');
        print('Latitude: ${location[LocationTable.columnLatitude]}');
        print('Longitude: ${location[LocationTable.columnLongitude]}');
        print('Partie Nr: ${location[LocationTable.columnPartieNr]}');
        print('Contract: ${location[LocationTable.columnContract]}');
        print('Additional Info: ${location[LocationTable.columnAdditionalInfo]}');
        print('Access: ${location[LocationTable.columnAccess]}');
        print('Sawmill: ${location[LocationTable.columnSawmill]}');
        print('Oversize Sawmill: ${location[LocationTable.columnOversizeSawmill]}');
        print('Normal Quantity: ${location[LocationTable.columnNormalQuantity]}');
        print('Oversize Quantity: ${location[LocationTable.columnOversizeQuantity]}');
        print('Piece Count: ${location[LocationTable.columnPieceCount]}');
        print('Photo IDs: ${location[LocationTable.columnPhotoIds]}');
        print('Photo URLs: ${location[LocationTable.columnPhotoUrls]}');
      }
    } catch (e) {
      print('Error querying locations: $e');
    }
  }

  Future<int> insertLocation(Location location) async {
    final db = await database;

    final values = {
      LocationTable.columnId: location.id,
      LocationTable.columnUserId: 0,
      LocationTable.columnLastEdited: location.lastEdited.millisecondsSinceEpoch,
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
      LocationTable.columnPhotoIds: json.encode(location.photoIds ?? []),
      LocationTable.columnPhotoUrls: jsonEncode(location.photoUrls ?? []),
    };

    return await db.insert(LocationTable.tableName, values);
  }

  Future<Location?> getLocation(int id) async {
    final db = await database;
    final maps = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _locationFromMap(maps.first);
  }

  Future<List<Location>> getAllLocations() async {
    final db = await database;
    final maps = await db.query(LocationTable.tableName);
    return maps.map((map) => _locationFromMap(map)).toList();
  }

  Future<int> updateLocation(Location location) async {
    final db = await database;

    final values = {
      LocationTable.columnId: location.id,
      LocationTable.columnUserId: 0,
      LocationTable.columnLastEdited: location.lastEdited.millisecondsSinceEpoch,
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

    return await db.update(
      LocationTable.tableName,
      values,
      where: '${LocationTable.columnId} = ?',
      whereArgs: [location.id],
    );
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    return await db.delete(
      LocationTable.tableName,
      where: '${LocationTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  Location _locationFromMap(Map<String, dynamic> map) {
    return Location(
      id: map[LocationTable.columnId] as int,
      userId: map[LocationTable.columnUserId] as String,
      lastEdited: DateTime.fromMillisecondsSinceEpoch(
          map[LocationTable.columnLastEdited] as int),
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

  Future<void> printAllShipments() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(ShipmentTable.tableName);

      if (maps.isEmpty) {
        print('No shipments found in database');
        return;
      }

      print('Found ${maps.length} shipments:');
      for (var shipment in maps) {
        print('-----------------------------------');
        print('ID: ${shipment[ShipmentTable.columnId]}');
        print('User ID: ${shipment[ShipmentTable.columnUserId]}');
        print('Location ID: ${shipment[ShipmentTable.columnLocationId]}');
        print('Date: ${DateTime.fromMillisecondsSinceEpoch(shipment[ShipmentTable.columnDate])}');
        print('Contract: ${shipment[ShipmentTable.columnContract]}');
        print('Additional Info: ${shipment[ShipmentTable.columnAdditionalInfo]}');
        print('Sawmill: ${shipment[ShipmentTable.columnSawmill]}');
        print('Normal Quantity: ${shipment[ShipmentTable.columnNormalQuantity]}');
        print('Oversize Quantity: ${shipment[ShipmentTable.columnOversizeQuantity]}');
        print('Piece Count: ${shipment[ShipmentTable.columnPieceCount]}');
      }
    } catch (e) {
      print('Error querying shipments: $e');
    }
  }

  Future<int> insertShipment(Shipment shipment) async {
    final db = await database;

    final values = {
      ShipmentTable.columnId: shipment.id,
      ShipmentTable.columnUserId: shipment.userId,
      ShipmentTable.columnLocationId: shipment.locationId,
      ShipmentTable.columnDate: shipment.date.millisecondsSinceEpoch,
      ShipmentTable.columnContract: shipment.contract,
      ShipmentTable.columnAdditionalInfo: shipment.additionalInfo,
      ShipmentTable.columnSawmill: shipment.sawmill,
      ShipmentTable.columnNormalQuantity: shipment.normalQuantity,
      ShipmentTable.columnOversizeQuantity: shipment.oversizeQuantity,
      ShipmentTable.columnPieceCount: shipment.pieceCount,
    };

    return await db.insert(ShipmentTable.tableName, values);
  }

  Future<Shipment?> getShipment(int id) async {
    final db = await database;
    final maps = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _shipmentFromMap(maps.first);
  }

  Future<List<Shipment>> getShipmentsByLocation(int locationId) async {
    final db = await database;
    final maps = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnLocationId} = ?',
      whereArgs: [locationId],
      orderBy: '${ShipmentTable.columnDate} DESC',
    );
    return maps.map((map) => _shipmentFromMap(map)).toList();
  }

  Future<List<Shipment>> getAllShipments() async {
    final db = await database;
    final maps = await db.query(ShipmentTable.tableName);
    return maps.map((map) => _shipmentFromMap(map)).toList();
  }

  Future<int> updateShipment(Shipment shipment) async {
    final db = await database;

    final values = {
      ShipmentTable.columnId: shipment.id,
      ShipmentTable.columnUserId: shipment.userId,
      ShipmentTable.columnLocationId: shipment.locationId,
      ShipmentTable.columnDate: shipment.date.millisecondsSinceEpoch,
      ShipmentTable.columnContract: shipment.contract,
      ShipmentTable.columnAdditionalInfo: shipment.additionalInfo,
      ShipmentTable.columnSawmill: shipment.sawmill,
      ShipmentTable.columnNormalQuantity: shipment.normalQuantity,
      ShipmentTable.columnOversizeQuantity: shipment.oversizeQuantity,
      ShipmentTable.columnPieceCount: shipment.pieceCount,
    };

    return await db.update(
      ShipmentTable.tableName,
      values,
      where: '${ShipmentTable.columnId} = ?',
      whereArgs: [shipment.id],
    );
  }

  Future<int> deleteShipment(int id) async {
    final db = await database;
    return await db.delete(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  Shipment _shipmentFromMap(Map<String, dynamic> map) {
    return Shipment(
      id: map[ShipmentTable.columnId] as int,
      userId: map[ShipmentTable.columnUserId] as String,
      locationId: map[ShipmentTable.columnLocationId] as int,
      date: DateTime.fromMillisecondsSinceEpoch(
          map[ShipmentTable.columnDate] as int),
      contract: map[ShipmentTable.columnContract] as String?,
      additionalInfo: map[ShipmentTable.columnAdditionalInfo] as String?,
      sawmill: map[ShipmentTable.columnSawmill] as String,
      normalQuantity: map[ShipmentTable.columnNormalQuantity] as double?,
      oversizeQuantity: map[ShipmentTable.columnOversizeQuantity] as double?,
      pieceCount: map[ShipmentTable.columnPieceCount] as int,
    );
  }
}
