import 'package:holz_logistik_backend/api/user_api.dart';

/// {@template user_api}
/// The interface for an API that provides access to users.
/// {@endtemplate}
abstract class UserApi {
  /// {@macro user_api}
  const UserApi();

  /// Provides a stream of users
  Stream<Map<String, User>> get users;

  /// Saves or updates a [user].
  ///
  /// If a [user] with the same id already exists, it will be updated.
  Future<void> saveUser(User user);

  /// Deletes the `user` with the given [id].
  Future<void> deleteUser(String id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}
