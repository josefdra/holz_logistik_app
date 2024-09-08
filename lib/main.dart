import 'package:flutter/material.dart';
import 'package:holz_logistik/app.dart';
import 'package:holz_logistik/services/api_service.dart';
import 'package:holz_logistik/services/auth_service.dart';
import 'package:holz_logistik/services/location_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final apiService = ApiService();
  final locationService = LocationService(apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        Provider(create: (_) => locationService),
      ],
      child: App(),
    ),
  );
}
