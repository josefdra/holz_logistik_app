import 'package:flutter/material.dart';
import 'package:holz_logistik/screens/login_screen.dart';
import 'package:holz_logistik/screens/main_screen.dart';
import 'package:holz_logistik/screens/register_screen.dart';
import 'package:holz_logistik/screens/reset_password_screen.dart';
import 'package:holz_logistik/screens/settings_screen.dart';
import 'package:holz_logistik/screens/splash_screen.dart';
import 'package:holz_logistik/services/auth_service.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holz Logistik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          if (authService.isInitializing) {
            return SplashScreen();
          } else if (authService.isAuthenticated) {
            return MainScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/reset-password': (context) => ResetPasswordScreen(),
        '/main': (context) => MainScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
