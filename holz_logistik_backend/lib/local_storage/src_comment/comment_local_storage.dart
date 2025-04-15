import 'package:holz_logistik_backend/api/comment_api.dart';
import 'package:holz_logistik_backend/local_storage/comment_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

/// {@template comment_local_storage}
/// A flutter implementation of the comment CommentLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class CommentLocalStorage extends CommentApi {
  /// {@macro comment_local_storage}
  CommentLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(CommentTable.createTable)
      ..registerMigration(_migrateCommentTable);

    _init();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _commentStreamController =
      BehaviorSubject<Map<String, List<Comment>>>.seeded(
    const {},
  );

  late final Stream<Map<String, List<Comment>>> _broadcastCommentsByNote =
      _commentStreamController.stream;

  /// Migration function for comment table
  Future<void> _migrateCommentTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Initialization
  Future<void> _init() async {
    final commentsJson = await _coreLocalStorage.getAll(CommentTable.tableName);

    final commentsByNoteId = <String, List<Comment>>{};

    for (final commentData in commentsJson) {
      final comment = Comment.fromJson(Map<String, dynamic>.from(commentData));

      if (!commentsByNoteId.containsKey(comment.noteId)) {
        commentsByNoteId[comment.noteId] = [];
      }

      commentsByNoteId[comment.noteId]!.add(comment);
    }
    _commentStreamController.add(commentsByNoteId);
  }

  @override
  Stream<Map<String, List<Comment>>> get commentsByNote =>
      _broadcastCommentsByNote;

  @override
  Map<String, List<Comment>> get currentCommentsByNote =>
      _commentStreamController.value;

  /// Insert or Update a `comment` to the database based on [commentData]
  Future<int> _insertOrUpdateComment(Map<String, dynamic> commentData) async {
    return _coreLocalStorage.insertOrUpdate(
      CommentTable.tableName,
      commentData,
    );
  }

  /// Insert or Update a [comment]
  @override
  Future<int> saveComment(Comment comment) {
    final currentCommentsByNote = _commentStreamController.value;
    if (!currentCommentsByNote.containsKey(comment.noteId)) {
      currentCommentsByNote[comment.noteId] = [];
    }

    currentCommentsByNote[comment.noteId]!.add(comment);
    _commentStreamController.add(currentCommentsByNote);

    return _insertOrUpdateComment(comment.toJson());
  }

  /// Delete a Comment from the database based on [id]
  Future<int> _deleteComment(String id) async {
    return _coreLocalStorage.delete(CommentTable.tableName, id);
  }

  /// Delete a Comment based on [id] and [noteId]
  @override
  Future<int> deleteComment({
    required String id,
    required String noteId,
  }) async {
    final currentCommentsByNote = _commentStreamController.value;

    currentCommentsByNote[noteId]!.removeWhere((c) => c.id == id);

    if (currentCommentsByNote[noteId]!.isEmpty) {
      currentCommentsByNote.remove(noteId);
    }
    _commentStreamController.add(currentCommentsByNote);

    return _deleteComment(id);
  }

  /// Close the [_commentStreamController]
  @override
  Future<void> close() {
    return _commentStreamController.close();
  }
}
