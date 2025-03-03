import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}