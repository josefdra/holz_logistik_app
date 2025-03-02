// lib/database/tables/location_table.dart

class LocationTable {
  static const String tableName = 'locations';

  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  static const String columnAdditionalInfo = 'additional_info';
  static const String columnAccess = 'access';
  static const String columnPartNumber = 'part_number';
  static const String columnSawmill = 'sawmill';
  static const String columnOversizeQuantity = 'oversize_quantity';
  static const String columnQuantity = 'quantity';
  static const String columnPieceCount = 'piece_count';
  static const String columnPhotoUrls = 'photo_urls'; // Stored as JSON string
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  // New columns for sync
  static const String columnServerId = 'server_id';
  static const String columnIsSynced = 'is_synced';
  static const String columnIsDeleted = 'is_deleted';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnName TEXT NOT NULL,
      $columnLatitude REAL NOT NULL,
      $columnLongitude REAL NOT NULL,
      $columnAdditionalInfo TEXT,
      $columnAccess TEXT,
      $columnPartNumber TEXT,
      $columnSawmill TEXT,
      $columnOversizeQuantity INTEGER,
      $columnQuantity INTEGER,
      $columnPieceCount INTEGER,
      $columnPhotoUrls TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnServerId TEXT,
      $columnIsSynced INTEGER NOT NULL DEFAULT 0,
      $columnIsDeleted INTEGER NOT NULL DEFAULT 0
    )
  ''';
}