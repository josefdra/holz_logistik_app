import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/providers/location_provider.dart';
import 'package:holz_logistik/providers/sync_provider.dart';
import 'package:holz_logistik/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Geolocator.requestPermission();
  }

  runApp(const MyApp());
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  final SyncProvider syncProvider;

  AppLifecycleObserver(this.syncProvider);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncProvider.syncOnAppResume();
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SyncProvider _syncProvider;
  late LocationProvider _locationProvider;
  late AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();

    _syncProvider = SyncProvider();
    _locationProvider = LocationProvider();
    _locationProvider.setSyncProvider(_syncProvider);

    _lifecycleObserver = AppLifecycleObserver(_syncProvider);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _locationProvider),
        ChangeNotifierProvider.value(value: _syncProvider),
      ],
      child: MaterialApp(
        title: 'Holz Logistik',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2C5E1A),
            primary: const Color(0xFF2C5E1A),
            secondary: const Color(0xFF8d693a),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2C5E1A),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF2C5E1A),
            foregroundColor: Colors.white,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}