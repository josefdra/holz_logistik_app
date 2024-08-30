import 'dart:io';

import 'package:holz_logistik/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createHttpClient({bool allowBadCertificates = false}) {
  HttpClient httpClient = HttpClient()
    ..connectionTimeout = Duration(milliseconds: ApiConfig.connectionTimeout)
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => allowBadCertificates);

  return IOClient(httpClient);
}
