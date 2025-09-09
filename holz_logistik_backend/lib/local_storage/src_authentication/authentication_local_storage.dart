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

  static const _versionKey = '__version_key__';
  static const _keysMapKey = '__keys_map__';

  final CoreLocalStorage _coreLocalStorage;
  late final Map<String, String> _keyMap;

  // StreamController to broadcast updates on authentication
  final _authenticationStreamController = BehaviorSubject<User>.seeded(User());

  /// Stream of authenticated user
  @override
  Stream<User> get authenticatedUser => _authenticationStreamController.stream;

  /// Authenticated user
  @override
  Future<User> get currentUser => getActiveUser();

  /// Active database
  @override
  Future<String> get activeDb => getActiveDb();

  /// Users databases
  @override
  Future<List<String>> get databaseList => getDatabaseList();

  /// Active api key
  @override
  Future<String> get apiKey => getActiveApiKey();

  /// Banned status
  @override
  Future<bool> get bannedStatus => getBannedStatus();

  Future<void> _init() async {
    await _migrate();
    _keyMap = await _loadKeyMap();
    final user = await getActiveUser();

    _authenticationStreamController.add(user);
  }

  Future<void> _migrate() async {
    final version = await _getIntFromPrefs(_versionKey);

    if (version == null) {
      await _migrateToV1();
    }
  }

  Future<void> _migrateToV1() async {
    const oldApiKeyKey = '__api_key__';
    const oldUserStorageKey = '__auth_collection_key__';

    final dummyUserDataString = jsonEncode(User());
    final activeUserData =
        await _getStringFromPrefs(oldUserStorageKey) ?? dummyUserDataString;
    final activeApiKey = await _getStringFromPrefs(oldApiKeyKey) ?? '';
    final dbName = activeApiKey.split('-').first;

    final keyMap = {
      'device_banned_key': '__device_banned_key__',
      'active_user_key': '__active_user_key__',
      'active_api_key_key': '__active_api_key_key__',
      'active_db_key': '__active_db_key__',
      'db_to_key_map_key': '__db_to_key_map_key__',
    };
    final dbToKeyMapString = jsonEncode({dbName: activeApiKey});
    final keyMapString = jsonEncode(keyMap);

    final deviceBannedKey = keyMap['device_banned_key']!;
    final activeUserKey = keyMap['active_user_key']!;
    final activeApiKeyKey = keyMap['active_api_key_key']!;
    final activeDbKey = keyMap['active_db_key']!;
    final dbToKeyMapKey = keyMap['db_to_key_map_key']!;

    await _setIntToPrefs(deviceBannedKey, 0);
    await _setStringToPrefs(activeUserKey, activeUserData);
    await _setStringToPrefs(activeApiKeyKey, activeApiKey);
    await _setStringToPrefs(activeDbKey, dbName);
    await _setStringToPrefs(dbToKeyMapKey, dbToKeyMapString);
    await _setStringToPrefs(_keysMapKey, keyMapString);

    await _setIntToPrefs(_versionKey, 1);
    await _deleteValueFromPrefs(oldApiKeyKey);
    await _deleteValueFromPrefs(oldUserStorageKey);
  }

  Future<String?> _getStringFromPrefs(String key) async {
    final prefs = await _coreLocalStorage.sharedPreferences;

    return prefs.getString(key);
  }

  Future<int?> _getIntFromPrefs(String key) async {
    final prefs = await _coreLocalStorage.sharedPreferences;

    return prefs.getInt(key);
  }

  Future<bool> _setStringToPrefs(String key, String value) async {
    final prefs = await _coreLocalStorage.sharedPreferences;

    return prefs.setString(key, value);
  }

  Future<bool> _setIntToPrefs(String key, int value) async {
    final prefs = await _coreLocalStorage.sharedPreferences;

    return prefs.setInt(key, value);
  }

  Future<void> _deleteValueFromPrefs(String key) async {
    final prefs = await _coreLocalStorage.sharedPreferences;
    await prefs.remove(key);
  }

  Future<Map<String, String>> _loadKeyMap() async {
    final keyMapJson = await _getStringFromPrefs(_keysMapKey);

    if (keyMapJson != null) {
      final decoded = jsonDecode(keyMapJson) as Map<String, dynamic>;
      return decoded.cast<String, String>();
    } else {
      return {};
    }
  }

  /// Checks if the user is banned
  Future<bool> getBannedStatus() async {
    final deviceBannedKey = _keyMap['device_banned_key']!;
    final deviceBanned = await _getIntFromPrefs(deviceBannedKey);

    if (deviceBanned != null && deviceBanned == 1) {
      return true;
    }

    return false;
  }

  /// Gets the current authenticated user. Returns an emtpy new user if empty.
  Future<User> getActiveUser() async {
    final activeUserKey = _keyMap['active_user_key']!;
    final userData = await _getStringFromPrefs(activeUserKey);

    if (userData != null) {
      final userJson = jsonDecode(userData) as Map<String, dynamic>;
      return User.fromJson(userJson);
    }

    return User();
  }

  /// Gets the active api key
  Future<String> getActiveApiKey() async {
    final activeApiKeyKey = _keyMap['active_api_key_key']!;
    final activeApiKey = await _getStringFromPrefs(activeApiKeyKey);

    if (activeApiKey != null) {
      return activeApiKey;
    }

    return '';
  }

  /// Gets the active database
  Future<String> getActiveDb() async {
    final activeDbKey = _keyMap['active_db_key']!;
    final activeDb = await _getStringFromPrefs(activeDbKey);

    if (activeDb != null) {
      return activeDb;
    }

    return '';
  }

  /// Gets the database list
  Future<List<String>> getDatabaseList() async {
    final dbToKeyMapKey = _keyMap['db_to_key_map_key']!;
    final dbToKeyMapJson = await _getStringFromPrefs(dbToKeyMapKey);

    if (dbToKeyMapJson != null) {
      final decoded = jsonDecode(dbToKeyMapJson) as Map<String, dynamic>;
      final dbToKeyMap = decoded.cast<String, String>();
      return dbToKeyMap.keys.toList();
    }

    return [];
  }

  @override
  Future<void> setActiveUser(User user) async {
    _authenticationStreamController.add(user);

    final activeUserKey = _keyMap['active_user_key']!;
    await _setStringToPrefs(activeUserKey, json.encode(user));
  }

  @override
  Future<void> setActiveDb(String dbName) async {
    final activeDbKey = _keyMap['active_db_key']!;
    final activeApiKeyKey = _keyMap['active_api_key_key']!;
    final dbToKeyMapKey = _keyMap['db_to_key_map_key']!;

    final dbToKeyMapJson = await _getStringFromPrefs(dbToKeyMapKey);

    if (dbToKeyMapJson != null) {
      final decoded = jsonDecode(dbToKeyMapJson) as Map<String, dynamic>;
      final dbToKeyMap = decoded.cast<String, String>();
      final apiKey = dbToKeyMap[dbName]!;

      await _setStringToPrefs(activeDbKey, dbName);
      await _setStringToPrefs(activeApiKeyKey, apiKey);
    }
  }

  @override
  Future<void> addDb(String apiKey) async {
    final parts = apiKey.split('-');
    final dbName = parts.first;

    final activeDbKey = _keyMap['active_db_key']!;
    final activeApiKeyKey = _keyMap['active_api_key_key']!;
    final dbToKeyMapKey = _keyMap['db_to_key_map_key']!;
    var dbToKeyMapJson = await _getStringFromPrefs(dbToKeyMapKey);

    if (dbToKeyMapJson != null) {
      final dbToKeyMap = jsonDecode(dbToKeyMapJson) as Map<String, String>;
      dbToKeyMap[dbName] = apiKey;
      dbToKeyMapJson = jsonEncode(dbToKeyMap);

      await _setStringToPrefs(activeDbKey, dbName);
      await _setStringToPrefs(activeApiKeyKey, apiKey);
      await _setStringToPrefs(dbToKeyMapKey, dbToKeyMapJson);
    }
  }

  @override
  Future<void> setBannedStatus({required bool bannedStatus}) async {
    final bannedInt = bannedStatus == true ? 1 : 0;
    final deviceBannedKey = _keyMap['device_banned_key']!;
    await _setIntToPrefs(deviceBannedKey, bannedInt);
  }

  @override
  Future<void> close() {
    return _authenticationStreamController.close();
  }
}
