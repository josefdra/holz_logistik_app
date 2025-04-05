import 'package:holz_logistik_backend/local_storage/user_local_storage.dart';

/// Provides constants and utilities for working with
/// the "notes" database table.
class NoteTable {
  /// The name of the database table
  static const String tableName = 'notes';

  /// The column name for the primary key identifier of a note.
  static const String columnId = 'id';

  /// The column name for storing the timestamp when a note was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for storing the text of the comment.
  static const String columnText = 'text';

  /// The column name for storing the id of the user that created the note.
  static const String columnUserId = 'userId';

  /// SQL statement for creating the notes table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnLastEdit TEXT NOT NULL,
      $columnText TEXT NOT NULL,
      $columnUserId TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES ${UserTable.tableName}(${UserTable.columnId})
    )
  ''';
}
