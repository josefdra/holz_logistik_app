import 'package:holz_logistik_backend/api/comment_api.dart';

/// {@template comment_api}
/// The interface for an API that provides access to comments.
/// {@endtemplate}
abstract class CommentApi {
  /// {@macro comment_api}
  const CommentApi();

  /// Provides a [Stream] of all comments.
  Stream<List<Comment>> get comments;

  /// Saves or updates a [comment].
  ///
  /// If a [comment] with the same id already exists, it will be updated.
  Future<void> saveComment(Comment comment);

  /// Deletes the `comment` with the given [id].
  ///
  /// If no `comment` with the given id exists, a [CommentNotFoundException] 
  /// error is thrown.
  Future<void> deleteComment(int id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}

/// Error thrown when a [Comment] with a given id is not found.
class CommentNotFoundException implements Exception {}
