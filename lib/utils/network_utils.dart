import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NetworkUtils {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<http.Response> authenticatedGet(String url) async {
    final token = await _getToken();
    return http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  static Future<http.Response> authenticatedPost(
      String url, dynamic body) async {
    final token = await _getToken();
    return http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
  }

  static Future<http.StreamedResponse> authenticatedMultipartRequest(
      http.MultipartRequest request) async {
    final token = await _getToken();
    request.headers['Authorization'] = 'Bearer $token';
    return request.send();
  }
}
