import 'package:holz_logistik_backend/api/user_api.dart';

/// {@template user_api}
/// The interface for an API that provides access to users.
/// {@endtemplate}
abstract class UserApi {
  /// {@macro user_api}
  const UserApi();

  /// Provides a stream of users
  Stream<Map<String, User>> get users;

  /// Gets the active database name
  String get dbName;

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate();

  /// Sets the last sync date
  Future<void> setLastSyncDate(String dbName, DateTime date);

  /// Gets updates
  Future<List<Map<String, dynamic>>> getUpdates();

  /// Saves or updates a [user].
  ///
  /// If a [user] with the same id already exists, it will be updated.
  Future<void> saveUser(User user, {bool fromServer = false, String? dbName});

  /// Marks a `user` with the given [id] as deleted.
  Future<void> markUserDeleted({required String id});

  /// Deletes the `user` with the given [id].
  Future<void> deleteUser({required String id, required String dbName});

  /// Sets synced
  Future<void> setSynced({required String id, required String dbName});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
