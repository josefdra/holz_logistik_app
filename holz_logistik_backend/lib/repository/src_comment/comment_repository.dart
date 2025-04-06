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
  Stream<List<Comment>> getComments() => _commentApi.comments;

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _commentApi.deleteComment(data['id'] as int);
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
  ///
  /// If no `comment` with the given id exists, a [CommentNotFoundException] 
  /// error is thrown.
  Future<void> deleteComment(int id) {
    _commentApi.deleteComment(id);
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
