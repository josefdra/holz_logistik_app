import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api/user_api.dart';

/// {@template users_local_storage}
/// A Flutter implementation of the [UserApi] that uses local storage.
/// {@endtemplate}
class UsersLocalStorage extends UserApi {
  /// {@macro users_local_storage}
  UsersLocalStorage({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;

  late final _userStreamController = BehaviorSubject<List<User>>.seeded(
    const [],
  );

  /// The key used for storing the users locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kUsersCollectionKey = '__users_collection_key__';

  String? _getValue(String key) => _plugin.getString(key);
  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);

  void _init() {
    final usersJson = _getValue(kUsersCollectionKey);
    if (usersJson != null) {
      final users = List<Map<dynamic, dynamic>>.from(
        json.decode(usersJson) as List,
      )
          .map((jsonMap) => User.fromJson(Map<String, dynamic>.from(jsonMap)))
          .toList();
      _userStreamController.add(users);
    } else {
      _userStreamController.add(const []);
    }
  }

  @override
  Stream<List<User>> getUsers() => _userStreamController.asBroadcastStream();

  @override
  Future<void> saveUser(User user) {
    final users = [..._userStreamController.value];
    final userIndex = users.indexWhere((t) => t.id == user.id);
    if (userIndex >= 0) {
      users[userIndex] = user;
    } else {
      users.add(user);
    }

    _userStreamController.add(users);
    return _setValue(kUsersCollectionKey, json.encode(users));
  }

  @override
  Future<void> deleteUser(int id) async {
    final users = [..._userStreamController.value];
    final userIndex = users.indexWhere((t) => t.id == id);
    if (userIndex == -1) {
      throw UserNotFoundException();
    } else {
      users.removeAt(userIndex);
      _userStreamController.add(users);
      return _setValue(kUsersCollectionKey, json.encode(users));
    }
  }

  @override
  Future<void> close() {
    return _userStreamController.close();
  }
}
