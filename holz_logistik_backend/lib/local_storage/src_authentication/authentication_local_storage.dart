import 'dart:async';
import 'dart:convert';

import 'package:holz_logistik_backend/api/authentication_api.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:rxdart/subjects.dart';

/// {@template authentication_local_storage}
/// A flutter implementation of the authentication local storage
/// {@endtemplate}
class AuthenticationLocalStorage extends AuthenticationApi {
  /// {@macro authentication_local_storage}
  AuthenticationLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    _init();
  }

  static const _authCollectionKey = '__auth_collection_key__';
  static const _apiKey = '__api_key__';

  final CoreLocalStorage _coreLocalStorage;

  // StreamController to broadcast updates on authentication
  final _authenticationStreamController = BehaviorSubject<User>.seeded(User());

  /// Stream of authenticated user
  @override
  Stream<User> get authenticatedUser => _authenticationStreamController.stream;

  /// Authenticated user
  @override
  Future<User> get currentUser => getUser();

  /// Authenticated user
  @override
  Future<String> get apiKey => getApiKey();

  Future<String?> _getValue(String key) async {
    final prefs = await _coreLocalStorage.sharedPreferences;

    return prefs.getString(key);
  }

  Future<void> _init() async {
    final storageData = await _getValue(_authCollectionKey);
    late final User user;

    if (storageData != null) {
      final userJson = jsonDecode(storageData) as Map<String, dynamic>;

      user = User.fromJson(userJson);
    } else {
      user = User();
    }

    _authenticationStreamController.add(user);
  }

  /// Gets the current authenticated user. Returns an emtpy new user if empty.
  Future<User> getUser() async {
    final storageData = await _getValue(_authCollectionKey);

    if (storageData != null) {
      final userJson = jsonDecode(storageData) as Map<String, dynamic>;

      return User.fromJson(userJson);
    } else {
      return User();
    }
  }

  /// Gets the api key
  Future<String> getApiKey() async {
    final apiKey = await _getValue(_apiKey);

    if (apiKey != null) {
      return apiKey;
    } else {
      return '';
    }
  }

  Future<bool> _setValue(String key, String value) async {
    final prefs = await _coreLocalStorage.sharedPreferences;

    return prefs.setString(key, value);
  }

  @override
  Future<void> updateAuthentication(User user) {
    _authenticationStreamController.add(user);

    return _setValue(_authCollectionKey, json.encode(user));
  }

  @override
  Future<void> setApiKey(String apiKey) {
    return _setValue(_apiKey, apiKey);
  }

  @override
  Future<bool> removeAuthentication() async {
    final prefs = await _coreLocalStorage.sharedPreferences;

    return prefs.remove(_authCollectionKey);
  }

  Future<void> _dispose() => _authenticationStreamController.close();

  @override
  Future<void> close() {
    return _dispose();
  }
}
