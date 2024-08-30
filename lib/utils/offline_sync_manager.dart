import 'dart:convert';

import 'package:holz_logistik/models/location.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OfflineSyncManager {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'offline_locations.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE locations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            latitude REAL,
            longitude REAL,
            description TEXT,
            part_number TEXT,
            sawmill TEXT,
            quantity TEXT,
            piece_count INTEGER,
            photo_urls TEXT,
            created_at TEXT,
            updated_at TEXT,
            is_synced INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Drop the old table and create a new one
          await db.execute('DROP TABLE IF EXISTS locations');
          await db.execute('''
            CREATE TABLE locations(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              latitude REAL,
              longitude REAL,
              description TEXT,
              part_number TEXT,
              sawmill TEXT,
              quantity TEXT,
              piece_count INTEGER,
              photo_urls TEXT,
              created_at TEXT,
              updated_at TEXT,
              is_synced INTEGER
            )
          ''');
        }
      },
    );
  }

  Future<void> saveLocation(Location location) async {
    final db = await database;
    await db.insert('locations', {
      'name': location.name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'description': location.description,
      'part_number': location.partNumber,
      'sawmill': location.sawmill,
      'quantity': location.quantity,
      'piece_count': location.pieceCount,
      'photo_urls': json.encode(location.photoUrls),
      'created_at': location.createdAt?.toIso8601String(),
      'updated_at': location.updatedAt?.toIso8601String(),
      'is_synced': 1,
    });
  }

  Future<void> updateLocation(Location location) async {
    final db = await database;
    await db.update(
      'locations',
      {
        'data': json.encode(location.toJson()),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  Future<void> deleteLocation(int id) async {
    final db = await database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markForDeletion(int id) async {
    final db = await database;
    await db.update(
      'locations',
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Location>> getOfflineLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations');
    return List.generate(maps.length, (i) {
      return Location(
        id: maps[i]['id'],
        name: maps[i]['name'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        description: maps[i]['description'],
        partNumber: maps[i]['part_number'],
        sawmill: maps[i]['sawmill'],
        quantity: maps[i]['quantity'],
        pieceCount: maps[i]['piece_count'],
        photoUrls: List<String>.from(json.decode(maps[i]['photo_urls'])),
        createdAt: DateTime.parse(maps[i]['created_at']),
        updatedAt: DateTime.parse(maps[i]['updated_at']),
      );
    });
  }

  Future<List<Location>> getUnsyncedLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('locations', where: 'is_synced = 0');
    return List.generate(maps.length, (i) {
      return Location.fromJson(json.decode(maps[i]['data']));
    });
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'locations',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> syncOfflineData() async {
    // This method should be implemented to sync data with the server
    // It should get unsynced locations, send them to the server,
    // and mark them as synced if successful
  }
}
