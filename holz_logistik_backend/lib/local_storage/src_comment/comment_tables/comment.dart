import 'package:holz_logistik_backend/local_storage/note_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/user_local_storage.dart';

/// Provides constants and utilities for working with
/// the "comments" database table.
class CommentTable {
  /// The name of the database table
  static const String tableName = 'comments';

  /// The column name for the primary key identifier of a comment.
  static const String columnId = 'id';

  /// The column name for storing when a comment was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for storing the comment text.
  static const String columnText = 'text';

  /// The column name for storing the id of the user that created the comment.
  static const String columnUserId = 'userId';

  /// The column name for storing the id of the user that created the comment.
  static const String columnNoteId = 'noteId';

  /// SQL statement for creating the comments table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnLastEdit TEXT NOT NULL,
      $columnText TEXT NOT NULL,
      $columnUserId TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES ${UserTable.tableName}(${UserTable.columnId}),
      FOREIGN KEY ($columnNoteId) REFERENCES ${NoteTable.tableName}(${NoteTable.columnId})
    )
  ''';
}
