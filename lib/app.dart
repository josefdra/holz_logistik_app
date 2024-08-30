import 'package:flutter/material.dart';
import 'package:holz_logistik/services/background_sync_service.dart';

import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/map_page.dart';
import 'screens/register_page.dart';
import 'screens/reset_password_page.dart';
import 'screens/settings_page.dart';
import 'screens/splash_screen.dart';

class App extends StatefulWidget {
  final BackgroundSyncService backgroundSyncService;

  App({required this.backgroundSyncService});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holz Logistik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => HomePage(),
        '/map': (context) => MapPage(),
        '/settings': (context) => SettingsPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/reset-password': (context) => ResetPasswordPage(),
      },
    );
  }

  @override
  void dispose() {
    widget.backgroundSyncService.stopPeriodicSync();
    super.dispose();
  }
}
