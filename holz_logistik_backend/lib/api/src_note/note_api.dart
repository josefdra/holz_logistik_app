import 'package:holz_logistik_backend/api/note_api.dart';

/// {@template note_api}
/// The interface for an API that provides access to notes.
/// {@endtemplate}
abstract class NoteApi {
  /// {@macro note_api}
  const NoteApi();

  /// Provides a [Stream] of all notes.
  Stream<List<Note>> get notes;

  /// Saves or updates a [note].
  ///
  /// If a [note] with the same id already exists, it will be updated.
  Future<void> saveNote(Note note);

  /// Deletes the `note` with the given [id].
  Future<void> deleteNote(String id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}
