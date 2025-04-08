import 'dart:async';

import 'package:holz_logistik_backend/api/comment_api.dart';
import 'package:holz_logistik_backend/sync/comment_sync_service.dart';

/// {@template comment_repository}
/// A repository that handles `comment` related requests.
/// {@endtemplate}
class CommentRepository {
  /// {@macro comment_repository}
  CommentRepository({
    required CommentApi commentApi,
    required CommentSyncService commentSyncService,
  })  : _commentApi = commentApi,
        _commentSyncService = commentSyncService {
    _commentSyncService.commentUpdates.listen(_handleServerUpdate);
  }

  final CommentApi _commentApi;
  final CommentSyncService _commentSyncService;

  /// Provides a [Stream] of all comments.
  Stream<Map<String, List<Comment>>> get commentsByNote =>
      _commentApi.commentsByNote;

  /// Provides all current comments
  Map<String, List<Comment>> get currentCommentsByNote =>
      _commentApi.currentCommentsByNote;

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _commentApi.deleteComment(
        id: data['id'] as String,
        noteId: data['noteId'] as String,
      );
    } else {
      _commentApi.saveComment(Comment.fromJson(data));
    }
  }

  /// Saves a [comment].
  ///
  /// If a [comment] with the same id already exists, it will be replaced.
  Future<void> saveComment(Comment comment) {
    _commentApi.saveComment(comment);
    return _commentSyncService.sendCommentUpdate(comment.toJson());
  }

  /// Deletes the `comment` with the given id.
  Future<void> deleteComment({required String id, required String noteId}) {
    _commentApi.deleteComment(id: id, noteId: noteId);
    final data = {
      'id': id,
      'deleted': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _commentSyncService.sendCommentUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _commentApi.close();
}
