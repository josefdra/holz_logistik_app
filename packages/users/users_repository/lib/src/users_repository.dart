import 'package:users_api/users_api.dart';

/// {@template users_repository}
/// A repository that handles `user` related requests.
/// {@endtemplate}
class UsersRepository {
  /// {@macro users_repository}
  const UsersRepository({
    required UsersApi usersApi,
  }) : _usersApi = usersApi;

  final UsersApi _usersApi;

  /// Provides a [Stream] of all users.
  Stream<List<User>> getUsers() => _usersApi.getUsers();

  /// Saves a [user].
  ///
  /// If a [user] with the same id already exists, it will be replaced.
  Future<void> saveUser(User user) => _usersApi.saveUser(user);

  /// Deletes the `user` with the given id.
  ///
  /// If no `user` with the given id exists, a [UserNotFoundException] error is
  /// thrown.
  Future<void> deleteUser(String id) => _usersApi.deleteUser(id);

  /// Disposes any resources managed by the repository.
  void dispose() => _usersApi.close();
}