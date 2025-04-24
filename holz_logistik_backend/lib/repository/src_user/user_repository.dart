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
    _init();
  }

  final UserApi _userApi;
  final UserSyncService _userSyncService;

  /// Provides a [Stream] of all users.
  Stream<Map<String, User>> get users => _userApi.users;

  void _init() {
    _userSyncService
      ..registerDateGetter(_userApi.getLastSyncDate)
      ..registerDataGetter(_userApi.getUpdates);
  }

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data.containsKey('newSyncDate')) {
      _userApi.setLastSyncDate(
        DateTime.fromMillisecondsSinceEpoch(
          data['newSyncDate'] as int,
          isUtc: true,
        ),
      );
    } else if (data['deleted'] == true || data['deleted'] == 1) {
      _userApi.deleteUser(
        id: data['id'] as String,
      );
    } else if (data['synced'] == true || data['synced'] == 1) {
      _userApi.setSynced(id: data['id'] as String);
    } else {
      final user = User.fromJson(data);
      _userApi.saveUser(user, fromServer: true);
    }
  }

  /// Saves a [user].
  ///
  /// If a [user] with the same id already exists, it will be replaced.
  Future<void> saveUser(User user) {
    final u = user.copyWith(lastEdit: DateTime.now());
    _userApi.saveUser(u);
    return _userSyncService.sendUserUpdate(u.toJson());
  }

  /// Saves a future user.
  Future<void> saveFutureUser(Future<User> userFuture) async {
    final user = await userFuture;
    await _userApi.saveUser(user);
  }

  /// Deletes the `user` with the given id.
  Future<void> deleteUser(String id) {
    _userApi.markUserDeleted(id: id);
    final data = {
      'id': id,
      'deleted': 1,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };

    return _userSyncService.sendUserUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _userApi.close();
}
