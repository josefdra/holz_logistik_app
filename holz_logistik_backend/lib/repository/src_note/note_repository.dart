import 'dart:async';

import 'package:holz_logistik_backend/api/note_api.dart';
import 'package:holz_logistik_backend/sync/note_sync_service.dart';

/// {@template note_repository}
/// A repository that handles `note` related requests.
/// {@endtemplate}
class NoteRepository {
  /// {@macro note_repository}
  NoteRepository({
    required NoteApi noteApi,
    required NoteSyncService noteSyncService,
  })  : _noteApi = noteApi,
        _noteSyncService = noteSyncService {
    _noteSyncService.noteUpdates.listen(_handleServerUpdate);
  }

  final NoteApi _noteApi;
  final NoteSyncService _noteSyncService;

  /// Provides a [Stream] of all notes.
  Stream<List<Note>> get notes => _noteApi.notes;

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _noteApi.deleteNote(data['id'] as String);
    } else {
      _noteApi.saveNote(Note.fromJson(data));
    }
  }

  /// Saves a [note].
  ///
  /// If a [note] with the same id already exists, it will be replaced.
  Future<void> saveNote(Note note) {
    _noteApi.saveNote(note);
    return _noteSyncService.sendNoteUpdate(note.toJson());
  }

  /// Deletes the `note` with the given id.
  ///
  /// If no `note` with the given id exists, a [NoteNotFoundException] error is
  /// thrown.
  Future<void> deleteNote(String id) {
    _noteApi.deleteNote(id);
    final data = {
      'id': id,
      'deleted': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _noteSyncService.sendNoteUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _noteApi.close();
}
