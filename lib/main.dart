import 'package:flutter/material.dart';
import 'package:holz_logistik/app.dart';
import 'package:holz_logistik/services/api_service.dart';
import 'package:holz_logistik/services/auth_service.dart';
import 'package:holz_logistik/services/image_service.dart';
import 'package:holz_logistik/services/location_service.dart';
import 'package:holz_logistik/utils/offline_sync_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final apiService = ApiService();
  final imageService = ImageService();
  final offlineSyncManager = OfflineSyncManager();
  final locationService =
      LocationService(apiService, imageService, offlineSyncManager);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        Provider(create: (_) => locationService),
        Provider(create: (_) => offlineSyncManager),
      ],
      child: App(),
    ),
  );
}
