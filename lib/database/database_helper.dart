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
  static const _databaseVersion = 4;

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
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE ${LocationTable.tableName} ADD COLUMN ${LocationTable.columnServerId} TEXT');
      await db.execute('ALTER TABLE ${LocationTable.tableName} ADD COLUMN ${LocationTable.columnIsSynced} INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE ${LocationTable.tableName} ADD COLUMN ${LocationTable.columnIsDeleted} INTEGER NOT NULL DEFAULT 0');

      await db.execute('ALTER TABLE ${ShipmentTable.tableName} ADD COLUMN ${ShipmentTable.columnServerId} TEXT');
      await db.execute('ALTER TABLE ${ShipmentTable.tableName} ADD COLUMN ${ShipmentTable.columnLocationServerId} TEXT');
      await db.execute('ALTER TABLE ${ShipmentTable.tableName} ADD COLUMN ${ShipmentTable.columnIsSynced} INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE ${ShipmentTable.tableName} ADD COLUMN ${ShipmentTable.columnIsDeleted} INTEGER NOT NULL DEFAULT 0');
    }

    if (oldVersion < 4) {
      try {
        await db.execute(ShipmentTable.addDriverNameColumn);
      } catch (e) {
        // Column might already exist, continue
      }
    }
  }

  // Location CRUD Operations
  Future<int> insertLocation(Location location) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final values = {
      LocationTable.columnServerId: location.serverId,
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
      LocationTable.columnIsSynced: location.isSynced ? 1 : 0,
      LocationTable.columnIsDeleted: location.isDeleted ? 1 : 0,
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

  Future<Location?> getLocationByServerId(String? serverId) async {
    if (serverId == null) return null;

    final db = await database;
    final maps = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnServerId} = ?',
      whereArgs: [serverId],
    );

    if (maps.isEmpty) return null;
    return _locationFromMap(maps.first);
  }

  Future<List<Location>> getAllLocations() async {
    final db = await database;
    final maps = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnIsDeleted} = 0',
    );
    return maps.map((map) => _locationFromMap(map)).toList();
  }

  Future<List<Location>> getLocationsUpdatedSince(DateTime timestamp) async {
    final db = await database;
    final maps = await db.query(
      LocationTable.tableName,
      where: '(${LocationTable.columnUpdatedAt} > ? AND ${LocationTable.columnIsSynced} = 0) OR ${LocationTable.columnIsSynced} = 0',
      whereArgs: [timestamp.toIso8601String()],
    );
    return maps.map((map) => _locationFromMap(map)).toList();
  }

  Future<int> updateLocation(Location location) async {
    final db = await database;
    final values = {
      LocationTable.columnServerId: location.serverId,
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
      LocationTable.columnIsSynced: location.isSynced ? 1 : 0,
      LocationTable.columnIsDeleted: location.isDeleted ? 1 : 0,
    };

    return await db.update(
      LocationTable.tableName,
      values,
      where: '${LocationTable.columnId} = ?',
      whereArgs: [location.id],
    );
  }

  Future<int> updateLocationServerId(int localId, String serverId) async {
    final db = await database;
    return await db.update(
      LocationTable.tableName,
      {
        LocationTable.columnServerId: serverId,
        LocationTable.columnIsSynced: 1,
      },
      where: '${LocationTable.columnId} = ?',
      whereArgs: [localId],
    );
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    return await db.update(
      LocationTable.tableName,
      {
        LocationTable.columnIsDeleted: 1,
        LocationTable.columnIsSynced: 0,
        LocationTable.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${LocationTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  Location _locationFromMap(Map<String, dynamic> map) {
    return Location(
      id: map[LocationTable.columnId] as int?,
      serverId: map[LocationTable.columnServerId] as String?,
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
      isSynced: map[LocationTable.columnIsSynced] == 1,
      isDeleted: map[LocationTable.columnIsDeleted] == 1,
    );
  }

  // Shipment CRUD Operations
  Future<int> insertShipment(Shipment shipment) async {
    final db = await database;
    return await db.insert(ShipmentTable.tableName, shipment.toMap());
  }

  Future<List<Shipment>> getShipmentsByLocation(int locationId) async {
    final db = await database;
    final maps = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnLocationId} = ? AND ${ShipmentTable.columnIsDeleted} = 0',
      whereArgs: [locationId],
      orderBy: '${ShipmentTable.columnTimestamp} DESC',
    );
    return maps.map((map) => Shipment.fromMap(map)).toList();
  }

  Future<Shipment?> getShipmentByServerId(String? serverId) async {
    if (serverId == null) return null;

    final db = await database;
    final maps = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnServerId} = ?',
      whereArgs: [serverId],
    );

    if (maps.isEmpty) return null;
    return Shipment.fromMap(maps.first);
  }

  Future<List<Shipment>> getShipmentsUpdatedSince(DateTime timestamp) async {
    final db = await database;
    final maps = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnTimestamp} > ? AND ${ShipmentTable.columnIsSynced} = 0',
      whereArgs: [timestamp.toIso8601String()],
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

  Future<int> updateShipmentServerId(int localId, String serverId) async {
    final db = await database;
    return await db.update(
      ShipmentTable.tableName,
      {
        ShipmentTable.columnServerId: serverId,
        ShipmentTable.columnIsSynced: 1,
      },
      where: '${ShipmentTable.columnId} = ?',
      whereArgs: [localId],
    );
  }

  Future<int> softDeleteShipment(int id) async {
    final db = await database;
    return await db.update(
      ShipmentTable.tableName,
      {
        ShipmentTable.columnIsDeleted: 1,
        ShipmentTable.columnIsSynced: 0,
      },
      where: '${ShipmentTable.columnId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<Shipment>> getAllShipments() async {
    final db = await database;
    final maps = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnIsDeleted} = 0',
    );
    return maps.map((map) => Shipment.fromMap(map)).toList();
  }
}