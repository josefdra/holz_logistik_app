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

  late final Stream<List<Note>> _notes =
      _noteStreamController.stream;

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

  /// Insert or Update a `note` to the database based on [noteData]
  Future<int> _insertOrUpdateNote(Map<String, dynamic> noteData) async {
    return _coreLocalStorage.insertOrUpdate(NoteTable.tableName, noteData);
  }

  /// Insert or Update a [note]
  @override
  Future<int> saveNote(Note note) async {
    final result = await _insertOrUpdateNote(note.toJson());
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
  Future<int> _deleteNote(String id) async {
    return _coreLocalStorage.delete(NoteTable.tableName, id);
  }

  /// Delete a Note based on [id]
  @override
  Future<int> deleteNote(String id) async {
    final result = await _deleteNote(id);
    final notes = [..._noteStreamController.value];
    final noteIndex = notes.indexWhere((n) => n.id == id);

    notes.removeAt(noteIndex);
    _noteStreamController.add(notes);

    return result;
  }

  /// Close the [_noteStreamController]
  @override
  Future<void> close() {
    return _noteStreamController.close();
  }
}
