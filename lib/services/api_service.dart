import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/data_item.dart';

class ApiService {
  final String baseUrl =
      'http://your-api-base-url.com'; // Replace with your actual API URL

  Future<List<DataItem>> fetchDataItems() async {
    final response = await http.get(Uri.parse('$baseUrl/data-items'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => DataItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data items');
    }
  }
}
