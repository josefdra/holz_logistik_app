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
  late final _commentStreamController = BehaviorSubject<List<Comment>>.seeded(
    const [],
  );

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
    final comments = commentsJson
        .map((comment) => Comment.fromJson(Map<String, dynamic>.from(comment)))
        .toList();
    _commentStreamController.add(comments);
  }

  /// Get the `comment`s from the [_commentStreamController]
  @override
  Stream<List<Comment>> get comments =>
      _commentStreamController.asBroadcastStream();

  /// Insert or Update a `comment` to the database based on [commentData]
  Future<int> _insertOrUpdateComment(Map<String, dynamic> commentData) async {
    return _coreLocalStorage.insertOrUpdate(
        CommentTable.tableName, commentData);
  }

  /// Insert or Update a [comment]
  @override
  Future<int> saveComment(Comment comment) {
    final comments = [..._commentStreamController.value];
    final commentIndex = comments.indexWhere((t) => t.id == comment.id);
    if (commentIndex >= 0) {
      comments[commentIndex] = comment;
    } else {
      comments.add(comment);
    }

    _commentStreamController.add(comments);
    return _insertOrUpdateComment(comment.toJson());
  }

  /// Delete a Comment from the database based on [id]
  Future<int> _deleteComment(int id) async {
    return _coreLocalStorage.delete(CommentTable.tableName, id);
  }

  /// Delete a Comment based on [id]
  @override
  Future<int> deleteComment(int id) async {
    final comments = [..._commentStreamController.value];
    final commentIndex = comments.indexWhere((t) => t.id == id);
    if (commentIndex == -1) {
      throw CommentNotFoundException();
    } else {
      comments.removeAt(commentIndex);
      _commentStreamController.add(comments);
      return _deleteComment(id);
    }
  }

  /// Close the [_commentStreamController]
  @override
  Future<void> close() {
    return _commentStreamController.close();
  }
}
