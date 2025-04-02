import 'package:user_api/user_api.dart';

/// {@template authentication_api}
/// A dart implementation of the authentication api
/// {@endtemplate}
abstract class AuthenticationApi {
  /// {@macro authentication_api}
  const AuthenticationApi();

  /// Provides a [Stream] of the authenticated user.
  ///
  /// If no `user` is authenticated it returns null.
  Stream<User?> getAuthenticatedUser();

  /// Adds the authentication of [user].
  Future<void> addAuthenticatedUser(User user);

  /// Removes the authenticated `user`.
  Future<void> removeAuthentication();

  /// Closes the client and frees up any resources.
  Future<void> close();
}
