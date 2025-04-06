import 'package:holz_logistik_backend/local_storage/location_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/sawmill_local_storage.dart';

/// Provides the junction between location and sawmill table
class LocationSawmillJunctionTable {
  /// The name of the database table
  static const String tableName = 'locationSawmillJunction';

  /// The column name for the locationId.
  static const String columnLocationId = 'locationId';

  /// The column name for the sawmillId.
  static const String columnSawmillId = 'sawmillId';

  /// SQL statement for creating the locationSawmillJunction table with the 
  /// defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnLocationId TEXT NOT NULL,
      $columnSawmillId TEXT NOT NULL,
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName}(${LocationTable.columnId})
      FOREIGN KEY ($columnSawmillId) REFERENCES ${SawmillTable.tableName}(${SawmillTable.columnId})
    )
  ''';
}
