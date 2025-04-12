import 'package:holz_logistik_backend/api/comment_api.dart';

/// {@template comment_api}
/// The interface for an API that provides access to comments.
/// {@endtemplate}
abstract class CommentApi {
  /// {@macro comment_api}
  const CommentApi();

  /// Provides a [Stream] of all comments.
  Stream<Map<String, List<Comment>>> get commentsByNote;

  /// Provides all current comments
  Map<String, List<Comment>> get currentCommentsByNote;

  /// Saves or updates a [comment].
  ///
  /// If a [comment] with the same id already exists, it will be updated.
  Future<void> saveComment(Comment comment);

  /// Deletes the `comment` with the given [id] and [noteId].
  Future<void> deleteComment({required String id, required String noteId});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
