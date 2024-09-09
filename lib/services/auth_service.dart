import 'package:flutter/foundation.dart';
import 'package:holz_logistik/models/user.dart';
import 'package:holz_logistik/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  bool _isInitializing = true;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _isInitializing;

  AuthService() {
    _initializeAuthentication();
  }

  Future<void> _initializeAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token != null) {
      try {
        await _getUserData(token);
      } catch (e) {
        // Token is invalid or expired
        await prefs.remove('accessToken');
      }
    }
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'username': username,
        'password': password,
      });

      final token = response['accessToken'];
      if (token == null) {
        throw Exception('Access token not found in response');
      }
      await _saveToken(token);

      // Instead of calling _getUserData here, set a dummy user
      _user = User(
          id: 1, username: username, email: 'dummy@email.com', role: 'user');
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  Future<void> _getUserData(String token) async {
    try {
      final response = await _apiService.get('/auth/user');
      _user = User.fromJson(response);
      notifyListeners();
    } catch (e) {
      // Don't throw an exception here, just log it
    }
  }

  Future<void> register(String username, String email, String password) async {
    await _apiService.post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<void> resetPassword(String email) async {
    await _apiService.post('/auth/reset-password-request', {
      'email': email,
    });
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    notifyListeners();
  }
}
