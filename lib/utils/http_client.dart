import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

// Create a custom HttpClient that accepts all certificates
HttpClient customHttpClient({bool allowBadCertificates = false}) {
  HttpClient httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => allowBadCertificates);

  return httpClient;
}

// Create an IOClient using the custom HttpClient
http.Client createHttpClient({bool allowBadCertificates = false}) {
  IOClient client =
      IOClient(customHttpClient(allowBadCertificates: allowBadCertificates));
  return client;
}
