class LocationTable {
  static const String tableName = 'locations';

  static const String columnId = 'id';
  static const String columnUserId = 'userId';
  static const String columnLastEdited = 'lastEdited';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  static const String columnPartieNr = 'partieNr';
  static const String columnContract = 'contract';
  static const String columnAdditionalInfo = 'additionalInfo';
  static const String columnAccess = 'access';
  static const String columnSawmill = 'sawmill';
  static const String columnOversizeSawmill = 'oversizeSawmill';
  static const String columnNormalQuantity = 'normalQuantity';
  static const String columnOversizeQuantity = 'oversizeQuantity';
  static const String columnPieceCount = 'pieceCount';
  static const String columnPhotoIds = 'photoIds';
  static const String columnPhotoUrls = 'photoUrls';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnUserId TEXT NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnLatitude REAL,
      $columnLongitude REAL,
      $columnPartieNr TEXT,
      $columnContract TEXT,
      $columnAdditionalInfo TEXT,
      $columnAccess TEXT,
      $columnSawmill TEXT,
      $columnOversizeSawmill TEXT,
      $columnNormalQuantity REAL,
      $columnOversizeQuantity REAL,
      $columnPieceCount INTEGER,
      $columnPhotoIds INTEGER,
      $columnPhotoUrls TEXT
    )
  ''';
}