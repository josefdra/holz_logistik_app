import 'dart:async';

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
    _listenToDatabaseSwitches();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _noteStreamController = BehaviorSubject<List<Note>>.seeded(
    const [],
  );

  late final Stream<List<Note>> _notes = _noteStreamController.stream;

  static const _syncFromServerKey = '__note_sync_from_server_date_key__';

  // Subscription to database switch events
  StreamSubscription<String>? _databaseSwitchSubscription;

  /// Migration function for note table
  Future<void> _migrateNoteTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Listen to database switch events and reload caches
  void _listenToDatabaseSwitches() {
    _databaseSwitchSubscription = _coreLocalStorage.onDatabaseSwitch.listen(
      (newDatabaseId) async {
        await _reloadCaches();
      },
    );
  }

  /// Reload all caches after database switch
  Future<void> _reloadCaches() async {
    try {
      _noteStreamController.add(const []);
      final notes = await _getAllNotes();
      _noteStreamController.add(notes);
    } catch (e) {
      _noteStreamController.add(const []);
    }
  }

  /// Initialization
  Future<void> _init() async {
    final notes = await _getAllNotes();
    _noteStreamController.add(notes);
  }

  /// Get all notes from current database
  Future<List<Note>> _getAllNotes() async {
    final notesJson = await _coreLocalStorage.getAll(NoteTable.tableName);
    final notes = notesJson
        .map((note) => Note.fromJson(Map<String, dynamic>.from(note)))
        .toList();
    return notes;
  }

  @override
  Stream<List<Note>> get notes => _notes;

  @override
  String get dbName => _coreLocalStorage.dbName;

  /// Provides the last sync date
  @override
  Future<DateTime> getLastSyncDate() =>
      _coreLocalStorage.getLastSyncDate(_syncFromServerKey);

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(String dbName, DateTime date) =>
      _coreLocalStorage.setLastSyncDate(dbName, _syncFromServerKey, date);

  /// Gets unsynced updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() =>
      _coreLocalStorage.getUpdates(NoteTable.tableName);

  /// Insert or Update a `note` to the database based on [noteData]
  Future<int> _insertOrUpdateNote(
    Map<String, dynamic> noteData, {
    String? dbName,
  }) async {
    return _coreLocalStorage.insertOrUpdate(
      NoteTable.tableName,
      noteData,
      dbName: dbName,
    );
  }

  /// Insert or Update a [note]
  @override
  Future<int> saveNote(
    Note note, {
    bool fromServer = false,
    String? dbName,
  }) async {
    final json = note.toJson();

    if (fromServer) {
      if (!(await _coreLocalStorage.isNewer(
        NoteTable.tableName,
        note.lastEdit,
        note.id,
      ))) {
        return 0;
      }

      json['synced'] = 1;
    } else {
      json['synced'] = 0;
      json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final result = await _insertOrUpdateNote(json, dbName: dbName);
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
  Future<void> _deleteNote(String id, String dbName) async {
    await _coreLocalStorage.delete(NoteTable.tableName, id, dbName);
  }

  /// Marks a Note as deleted based on [id]
  @override
  Future<void> markNoteDeleted({required String id}) async {
    final resultList =
        await _coreLocalStorage.getByIdForDeletion(NoteTable.tableName, id);

    if (resultList.isEmpty) return Future<void>.value();

    final json = Map<String, dynamic>.from(resultList.first);
    json['deleted'] = 1;
    json['synced'] = 0;
    await _insertOrUpdateNote(json);

    final notes = [..._noteStreamController.value]
      ..removeWhere((n) => n.id == id);

    _noteStreamController.add(notes);

    return Future<void>.value();
  }

  /// Delete a Note based on [id]
  @override
  Future<void> deleteNote({required String id, required String dbName}) async {
    final result =
        await _coreLocalStorage.getByIdForDeletion(NoteTable.tableName, id);

    if (result.isEmpty) return Future<void>.value();

    await _deleteNote(id, dbName);

    final notes = [..._noteStreamController.value]
      ..removeWhere((n) => n.id == id);

    _noteStreamController.add(notes);

    return Future<void>.value();
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id, required String dbName}) =>
      _coreLocalStorage.setSynced(NoteTable.tableName, id, dbName);

  /// Close the [_noteStreamController]
  @override
  Future<void> close() {
    _databaseSwitchSubscription?.cancel();
    return _noteStreamController.close();
  }
}
