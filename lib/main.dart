import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holz_logistik/data/sync_service.dart';
import 'package:provider/provider.dart';

import 'package:holz_logistik/data/data_provider.dart';
import 'package:holz_logistik/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Geolocator.requestPermission();
  }

  await dotenv.load();
  await SyncService.initializeUser();

  runApp(const HolzLogistik());
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {}
  }
}

class HolzLogistik extends StatefulWidget {
  const HolzLogistik({super.key});

  @override
  State<HolzLogistik> createState() => _HolzLogistikState();
}

class _HolzLogistikState extends State<HolzLogistik> {
  late DataProvider _dataProvider;
  late AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();

    _dataProvider = DataProvider();
    _dataProvider.init();
    _lifecycleObserver = AppLifecycleObserver();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _dataProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
