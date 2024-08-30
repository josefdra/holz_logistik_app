import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/location.dart';
import '../services/location_service.dart';

class OfflineSyncManager {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'offline_locations.db');
    return await openDatabase(
      path,
      version: 1,
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
            photos TEXT,
            new_photos TEXT,
            is_synced INTEGER
          )
        ''');
      },
    );
  }

  static Future<void> saveLocationOffline(Location location) async {
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
      'photos': location.photos.join(','),
      'new_photos': location.newPhotos.map((file) => file.path).join(','),
      'is_synced': 0,
    });
  }

  static Future<List<Location>> getOfflineLocations() async {
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
        photos: (maps[i]['photos'] as String).split(','),
        newPhotos: (maps[i]['new_photos'] as String)
            .split(',')
            .map((path) => File(path))
            .toList(),
      );
    });
  }

  static Future<void> syncOfflineLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('locations', where: 'is_synced = 0');

    for (var locationMap in maps) {
      try {
        Location location = Location(
          name: locationMap['name'],
          latitude: locationMap['latitude'],
          longitude: locationMap['longitude'],
          description: locationMap['description'],
          partNumber: locationMap['part_number'],
          sawmill: locationMap['sawmill'],
          quantity: locationMap['quantity'],
          pieceCount: locationMap['piece_count'],
          newPhotos: (locationMap['new_photos'] as String)
              .split(',')
              .map((path) => File(path))
              .toList(),
        );

        await LocationService.addLocation(location);

        await db.update('locations', {'is_synced': 1},
            where: 'id = ?', whereArgs: [locationMap['id']]);
      } catch (e) {
        print('Error syncing location: $e');
      }
    }
  }
}
