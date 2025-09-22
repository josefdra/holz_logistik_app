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
    _init();
  }

  final NoteApi _noteApi;
  final NoteSyncService _noteSyncService;

  /// Provides a [Stream] of all notes.
  Stream<List<Note>> get notes => _noteApi.notes;

  void _init() {
    _noteSyncService
      ..registerDateGetter(_noteApi.getLastSyncDate)
      ..registerDataGetter(_noteApi.getUpdates);
  }

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data.containsKey('newSyncDate')) {
      _noteApi.setLastSyncDate(
        data['dbName'] as String,
        DateTime.fromMillisecondsSinceEpoch(
          data['newSyncDate'] as int,
          isUtc: true,
        ),
      );
    } else if (data['deleted'] == true || data['deleted'] == 1) {
      _noteApi.deleteNote(
        id: data['id'] as String,
        dbName: data['dbName'] as String,
      );
    } else if (data['synced'] == true || data['synced'] == 1) {
      _noteApi.setSynced(
        id: data['id'] as String,
        dbName: data['dbName'] as String,
      );
    } else {
      final note = Note.fromJson(data);
      _noteApi.saveNote(note, fromServer: true);
    }
  }

  /// Saves a [note].
  ///
  /// If a [note] with the same id already exists, it will be replaced.
  Future<void> saveNote(Note note) {
    final n = note.copyWith(lastEdit: DateTime.now());
    _noteApi.saveNote(n);
    final dbName = _noteApi.dbName;

    return _noteSyncService.sendNoteUpdate(n.toJson(), dbName);
  }

  /// Deletes the `note` with the given id.
  Future<void> deleteNote(String id) async {
    await _noteApi.markNoteDeleted(id: id);
    final data = {
      'id': id,
      'deleted': 1,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
    final dbName = _noteApi.dbName;

    return _noteSyncService.sendNoteUpdate(data, dbName);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _noteApi.close();
}
