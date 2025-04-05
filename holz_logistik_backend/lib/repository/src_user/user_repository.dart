import 'dart:async';

import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/sync/user_sync_service.dart';

/// {@template user_repository}
/// A repository that handles `user` related requests.
/// {@endtemplate}
class UserRepository {
  /// {@macro user_repository}
  UserRepository({
    required UserApi userApi,
    required UserSyncService userSyncService,
  })  : _userApi = userApi,
        _userSyncService = userSyncService {
    _userSyncService.userUpdates.listen(_handleServerUpdate);
  }

  final UserApi _userApi;
  final UserSyncService _userSyncService;

  /// Provides a [Stream] of all users.
  Stream<List<User>> getUsers() => _userApi.getUsers();

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _userApi.deleteUser(data['id'] as int);
    } else {
      _userApi.saveUser(User.fromJson(data));
    }
  }

  /// Saves a [user].
  ///
  /// If a [user] with the same id already exists, it will be replaced.
  Future<void> saveUser(User user) {
    _userApi.saveUser(user);
    return _userSyncService.sendUserUpdate(user.toJson());
  }

  /// Deletes the `user` with the given id.
  ///
  /// If no `user` with the given id exists, a [UserNotFoundException] error is
  /// thrown.
  Future<void> deleteUser(int id) {
    _userApi.deleteUser(id);
    final data = {
      'id': id,
      'deleted': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _userSyncService.sendUserDeletion(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _userApi.close();
}
