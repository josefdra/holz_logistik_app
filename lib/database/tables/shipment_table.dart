// lib/database/tables/shipment_table.dart

import 'location_table.dart';

class ShipmentTable {
  static const String tableName = 'shipments';

  static const String columnId = 'id';
  static const String columnLocationId = 'location_id';
  static const String columnOversizeQuantity = 'oversize_quantity';
  static const String columnQuantity = 'quantity';
  static const String columnPieceCount = 'piece_count';
  static const String columnTimestamp = 'timestamp';
  static const String columnIsUndone = 'is_undone';
  // Sync columns
  static const String columnServerId = 'server_id';
  static const String columnLocationServerId = 'location_server_id';
  static const String columnIsSynced = 'is_synced';
  static const String columnIsDeleted = 'is_deleted';
  // New column for driver
  static const String columnDriverName = 'driver_name';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnLocationId INTEGER NOT NULL,
      $columnOversizeQuantity INTEGER,
      $columnQuantity INTEGER NOT NULL,
      $columnPieceCount INTEGER NOT NULL,
      $columnTimestamp TEXT NOT NULL,
      $columnIsUndone INTEGER NOT NULL DEFAULT 0,
      $columnServerId TEXT,
      $columnLocationServerId TEXT,
      $columnIsSynced INTEGER NOT NULL DEFAULT 0,
      $columnIsDeleted INTEGER NOT NULL DEFAULT 0,
      $columnDriverName TEXT,
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName} (${LocationTable.columnId})
    )
  ''';

  // Migration to add driver name column
  static const String addDriverNameColumn = '''
    ALTER TABLE $tableName 
    ADD COLUMN $columnDriverName TEXT
  ''';
}