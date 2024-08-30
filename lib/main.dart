import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:holz_logistik/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/background_sync_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  final backgroundSyncService = BackgroundSyncService();
  backgroundSyncService.startPeriodicSync();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: App(backgroundSyncService: backgroundSyncService),
    ),
  );
}
