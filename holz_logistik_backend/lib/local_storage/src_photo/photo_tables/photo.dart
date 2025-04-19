import 'package:holz_logistik_backend/local_storage/location_local_storage.dart';

/// Provides constants and utilities for working with
/// the "photos" database table.
class PhotoTable {
  /// The name of the database table
  static const String tableName = 'photos';

  /// The column name for the primary key identifier of a photo.
  static const String columnId = 'id';

  /// The column name for the timestamp when a photo was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for storing the binary photo data
  static const String columnPhoto = 'photoFile';

  /// The column name for storing the location id of the photo.
  static const String columnLocationId = 'locationId';

  /// SQL statement for creating the photos table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnLastEdit TEXT NOT NULL,
      $columnPhoto BLOB NOT NULL,
      $columnLocationId TEXT NOT NULL,
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName}(${LocationTable.columnId})
    )
  ''';
}
