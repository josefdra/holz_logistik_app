import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:holz_logistik/database/database_helper.dart';
import 'package:holz_logistik/utils/models.dart';

class SyncService {
  static final baseUrl = dotenv.env['BASE_URL'];
  static String name = 'Test Nutzer';
  static String apiKey = '';
  static bool hasCredentials = false;
  static late int lastSync;
  static final DatabaseHelper _db = DatabaseHelper.instance;

  static Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    lastSync = prefs.getInt('lastSync') ?? 0;

    if (!prefs.containsKey('apiKey')) {
      return;
    }

    name = prefs.getString('name')!;
    apiKey = prefs.getString('apiKey')!;
    hasCredentials = true;
  }

  static Future<void> updateUserData(String newName, String newApiKey) async {
    name = newName;
    apiKey = newApiKey;
    hasCredentials = true;

    lastSync = 0;
    await _db.updateDB(apiKey);
    await syncChanges();
  }

  static void updateLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    lastSync = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('lastSync', SyncService.lastSync);
  }

  static Future<Map<String, dynamic>> getUserData(String apiKey) async {
    final url = '$baseUrl/verify/$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
    };
  }

  static Future<void> syncChanges() async {
    final unSyncedChanges = await _db.getUnSyncedChanges(lastSync);
    final url = '$baseUrl/sync';
    final requestBody = {
      'lastSync': lastSync,
      'locations': unSyncedChanges["locations"],
      'shipments': unSyncedChanges["shipments"],
    };

    try {
      final response = await http.post(Uri.parse(url),
          headers: getAuthHeaders(), body: jsonEncode(requestBody));

      if (response.statusCode == 200) {
        updateLastSync();
        final responseData = jsonDecode(response.body);

        if (responseData['updatedLocations'] != null &&
            responseData['updatedLocations'] is List) {
          for (var json in responseData['updatedLocations']) {
            json['id'] = json['_id'];
            final location = Location.fromMap(json);
            await _db.insertOrUpdateLocation(location);
          }
        }

        if (responseData['newShipments'] != null &&
            responseData['newShipments'] is List) {
          for (var json in responseData['newShipments']) {
            json['id'] = json['_id'];
            final shipment = Shipment.fromMap(json);
            await _db.insertOrUpdateShipment(shipment);
          }
        }

        if (responseData['newUsers'] != null &&
            responseData['newUsers'] is List) {
          for (var json in responseData['newUsers']) {
            json['id'] = json['_id'];
            final user = User.fromMap(json);
            await _db.insertOrUpdateUser(user);
          }
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Sync failed: ${response.statusCode}, message: ${errorBody['message']}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
