import 'package:holz_logistik_backend/api/note_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/note_local_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

/// {@template note_local_storage}
/// A flutter implementation of the note NoteLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class NoteLocalStorage extends NoteApi {
  /// {@macro note_local_storage}
  NoteLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(NoteTable.createTable)
      ..registerMigration(_migrateNoteTable);

    _init();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _noteStreamController = BehaviorSubject<List<Note>>.seeded(
    const [],
  );

  late final Stream<List<Note>> _notes = _noteStreamController.stream;

  static const _syncFromServerKey = '__note_sync_from_server_date_key__';

  /// Migration function for note table
  Future<void> _migrateNoteTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Initialization
  Future<void> _init() async {
    final notesJson = await _coreLocalStorage.getAll(NoteTable.tableName);
    final notes = notesJson
        .map((note) => Note.fromJson(Map<String, dynamic>.from(note)))
        .toList();
    _noteStreamController.add(notes);
  }

  @override
  Stream<List<Note>> get notes => _notes;

  /// Provides the last sync date
  @override
  Future<DateTime> getLastSyncDate() =>
      _coreLocalStorage.getLastSyncDate(_syncFromServerKey);

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(DateTime date) =>
      _coreLocalStorage.setLastSyncDate(_syncFromServerKey, date);

  /// Gets unsynced updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() =>
      _coreLocalStorage.getUpdates(NoteTable.tableName);

  /// Insert or Update a `note` to the database based on [noteData]
  Future<int> _insertOrUpdateNote(Map<String, dynamic> noteData) async {
    return _coreLocalStorage.insertOrUpdate(NoteTable.tableName, noteData);
  }

  /// Insert or Update a [note]
  @override
  Future<int> saveNote(Note note, {bool fromServer = false}) async {
    final json = note.toJson();
    if (fromServer) json['synced'] = 1;

    final result = await _insertOrUpdateNote(json);
    final notes = [..._noteStreamController.value];
    final noteIndex = notes.indexWhere((n) => n.id == note.id);
    if (noteIndex > -1) {
      notes[noteIndex] = note;
    } else {
      notes.add(note);
    }

    _noteStreamController.add(notes);

    return result;
  }

  /// Delete a Note from the database based on [id]
  Future<void> _deleteNote(String id) async {
    await _coreLocalStorage.delete(NoteTable.tableName, id);
  }

  /// Marks a Note as deleted based on [id]
  @override
  Future<void> markNoteDeleted({required String id}) async {
    final noteJson = Map<String, dynamic>.from(
      (await _coreLocalStorage.getById(NoteTable.tableName, id)).first,
    );
    noteJson['deleted'] = 1;
    await _insertOrUpdateNote(noteJson);

    final notes = [..._noteStreamController.value]
      ..removeWhere((n) => n.id == id);

    _noteStreamController.add(notes);

    return Future<void>.value();
  }

  /// Delete a Note based on [id]
  @override
  Future<void> deleteNote({required String id}) => _deleteNote(id);

  /// Sets synced
  @override
  Future<void> setSynced({required String id}) =>
      _coreLocalStorage.setSynced(NoteTable.tableName, id);

  /// Close the [_noteStreamController]
  @override
  Future<void> close() {
    return _noteStreamController.close();
  }
}
