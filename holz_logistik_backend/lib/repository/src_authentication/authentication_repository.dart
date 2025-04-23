import 'dart:async';

import 'package:holz_logistik_backend/api/authentication_api.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/sync/authentication_sync_service.dart';

/// {@template authentication_repository}
/// A dart implementation of the repository for authentication
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    required AuthenticationApi authenticationApi,
    required AuthenticationSyncService authenticationSyncService,
  })  : _authenticationApi = authenticationApi,
        _authenticationSyncService = authenticationSyncService {
    _authenticationSyncService.authenticationUpdates
        .listen(_handleAuthenticationUpdates);
  }

  final AuthenticationApi _authenticationApi;
  final AuthenticationSyncService _authenticationSyncService;

  /// Provides a [Stream] of the authenticated user.
  Stream<User> get authenticatedUser => _authenticationApi.authenticatedUser;

  /// Provides the authenticated user.
  Future<User> get currentUser => _authenticationApi.currentUser;

  /// Provides the api key.
  Future<String> get apiKey => _authenticationApi.apiKey;

  /// Handle updates from Server
  void _handleAuthenticationUpdates(Map<String, dynamic> data) {
    if (data['authenticated'] == true || data['authenticated'] == 1) {
      _authenticationApi.updateAuthentication(User.fromJson(data));
    } else {
      _authenticationApi.removeAuthentication();
    }
  }

  /// Updates the apiKey and requests authentication
  Future<void> updateApiKey(String apiKey) {
    return _authenticationApi.setApiKey(apiKey);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _authenticationApi.close();
}
