import 'dart:io';

import 'package:holz_logistik/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createHttpClient() {
  HttpClient httpClient = HttpClient()
    ..connectionTimeout = Duration(milliseconds: ApiConfig.connectionTimeout);

  return IOClient(httpClient);
}
