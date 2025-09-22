import 'package:holz_logistik_backend/api/note_api.dart';

/// {@template note_api}
/// The interface for an API that provides access to notes.
/// {@endtemplate}
abstract class NoteApi {
  /// {@macro note_api}
  const NoteApi();

  /// Provides a [Stream] of all notes.
  Stream<List<Note>> get notes;

  /// Gets the active database name
  String get dbName;

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate();

  /// Sets the last sync date
  Future<void> setLastSyncDate(String dbName, DateTime date);

  /// Gets updates
  Future<List<Map<String, dynamic>>> getUpdates();

  /// Saves or updates a [note].
  ///
  /// If a [note] with the same id already exists, it will be updated.
  Future<void> saveNote(Note note, {bool fromServer = false, String? dbName});

  /// Marks a `note` with the given [id] as deleted.
  Future<void> markNoteDeleted({required String id});

  /// Deletes the `note` with the given [id].
  Future<void> deleteNote({required String id, required String dbName});

  /// Sets synced
  Future<void> setSynced({required String id, required String dbName});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
