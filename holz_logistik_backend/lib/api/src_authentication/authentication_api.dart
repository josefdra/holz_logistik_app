import 'package:holz_logistik_backend/api/user_api.dart';

/// {@template authentication_api}
/// A dart implementation of the authentication api
/// {@endtemplate}
abstract class AuthenticationApi {
  /// {@macro authentication_api}
  const AuthenticationApi();

  /// Provides a [Stream] of the current authenticated user.
  /// 
  /// Will return null if unauthenticated
  Stream<User> get authenticatedUser;

  /// Provides the current authenticated user.
  Future<User> get currentUser;

  /// Provides active database
  Future<String> get activeDb;

  /// Provides a list of the users databases
  Future<List<String>> get databaseList;

  /// Provides the api key.
  Future<String> get apiKey;

  /// Provides the banned status
  Future<bool> get bannedStatus;

  /// Sets the active [user]
  Future<void> setActiveUser(User user);

  /// Sets the active [apiKey]
  Future<void> setActiveApiKey(String apiKey);

  /// Sets the active [database]
  Future<void> setActiveDb(String database);

  /// Adds a new database and activates it
  Future<void> addDb(String apiKey);

  /// Sets the banned status of the user
  Future<void> setBannedStatus({required bool bannedStatus});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
