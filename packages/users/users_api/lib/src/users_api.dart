import 'package:users_api/users_api.dart';

/// {@template users_api}
/// The interface for an API that provides access to users.
/// {@endtemplate}
abstract class UsersAip {
  /// {@macro users_api}
  const UsersAip();

  /// Provides a [Stream] of all users.
  Stream<List<User>> getUsers();

  /// Saves a [user].
  ///
  /// If a [user] with the same id already exists, it will be replaced.
  Future<void> saveUser(User user);

  /// Deletes the `user` with the given id.
  ///
  /// If no `user` with the given id exists, a [UserNotFoundException] error is
  /// thrown.
  Future<void> deleteUser(int id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}

/// Error thrown when a [User] with a given id is not found.
class UserNotFoundException implements Exception {}