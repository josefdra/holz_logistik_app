import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holz_logistik/bootstrap.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    HttpOverrides.global = DesktopHttpOverrides();
  }

  if (Platform.isAndroid) {
    await Geolocator.requestPermission();
  }

  bootstrap();
}

class DesktopHttpOverrides extends HttpOverrides {
  static const trustedHosts = {
    'tile.openstreetmap.org',
    'a.tile.openstreetmap.org',
    'b.tile.openstreetmap.org',
    'c.tile.openstreetmap.org',
  };

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        if (trustedHosts.contains(host)) {
          return true;
        }

        return false;
      };
  }
}
