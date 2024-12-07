import 'dart:async';
import 'dart:convert';
import 'package:holz_logistik/database/tables/shipment_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/location.dart';
import '../models/shipment.dart';
import 'tables/location_table.dart';

class DatabaseHelper {
  static const _databaseName = "holz_logistik.db";
  static const _databaseVersion = 2;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(LocationTable.createTable);
    await db.execute(ShipmentTable.createTable);
  }

  // Location CRUD Operations
  Future<int> insertLocation(Location location) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final values = {
      LocationTable.columnName: location.name,
      LocationTable.columnLatitude: location.latitude,
      LocationTable.columnLongitude: location.longitude,
      LocationTable.columnAdditionalInfo: location.additionalInfo,
      LocationTable.columnAccess: location.access,
      LocationTable.columnPartNumber: location.partNumber,
      LocationTable.columnSawmill: location.sawmill,
      LocationTable.columnOversizeQuantity: location.oversizeQuantity,
      LocationTable.columnQuantity: location.quantity,
      LocationTable.columnPieceCount: location.pieceCount,
      LocationTable.columnPhotoUrls: jsonEncode(location.photoUrls),
      LocationTable.columnCreatedAt: now,
      LocationTable.columnUpdatedAt: now,
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
      LocationTable.columnName: location.name,
      LocationTable.columnLatitude: location.latitude,
      LocationTable.columnLongitude: location.longitude,
      LocationTable.columnAdditionalInfo: location.additionalInfo,
      LocationTable.columnAccess: location.access,
      LocationTable.columnPartNumber: location.partNumber,
      LocationTable.columnSawmill: location.sawmill,
      LocationTable.columnOversizeQuantity: location.oversizeQuantity,
      LocationTable.columnQuantity: location.quantity,
      LocationTable.columnPieceCount: location.pieceCount,
      LocationTable.columnPhotoUrls: jsonEncode(location.photoUrls),
      LocationTable.columnUpdatedAt: DateTime.now().toIso8601String(),
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
      id: map[LocationTable.columnId] as int?,
      name: map[LocationTable.columnName] as String,
      latitude: map[LocationTable.columnLatitude] as double,
      longitude: map[LocationTable.columnLongitude] as double,
      additionalInfo: map[LocationTable.columnAdditionalInfo] as String? ?? '',
      access: map[LocationTable.columnAccess] as String? ?? '',
      partNumber: map[LocationTable.columnPartNumber] as String? ?? '',
      sawmill: map[LocationTable.columnSawmill] as String? ?? '',
      oversizeQuantity: map[LocationTable.columnOversizeQuantity] as int?,
      quantity: map[LocationTable.columnQuantity] as int?,
      pieceCount: map[LocationTable.columnPieceCount] as int?,
      photoUrls: List<String>.from(
          jsonDecode(map[LocationTable.columnPhotoUrls] ?? '[]')
      ),
      createdAt: DateTime.parse(map[LocationTable.columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[LocationTable.columnUpdatedAt] as String),
    );
  }

  Future<int> insertShipment(Shipment shipment) async {
    final db = await database;
    return await db.insert(ShipmentTable.tableName, shipment.toMap());
  }

  Future<List<Shipment>> getShipmentsByLocation(int locationId) async {
    final db = await database;
    final maps = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnLocationId} = ?',
      whereArgs: [locationId],
      orderBy: '${ShipmentTable.columnTimestamp} DESC',
    );
    return maps.map((map) => Shipment.fromMap(map)).toList();
  }

  Future<int> updateShipment(Shipment shipment) async {
    final db = await database;
    return await db.update(
      ShipmentTable.tableName,
      shipment.toMap(),
      where: '${ShipmentTable.columnId} = ?',
      whereArgs: [shipment.id],
    );
  }

  Future<List<Shipment>> getAllShipments() async {
    final db = await database;
    final maps = await db.query(ShipmentTable.tableName);
    return maps.map((map) => Shipment.fromMap(map)).toList();
  }
}