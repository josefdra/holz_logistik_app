import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holz_logistik/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Geolocator.requestPermission();
  }

  bootstrap();
}
