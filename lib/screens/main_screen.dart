import 'package:flutter/material.dart';

import 'package:holz_logistik/utils/sync_service.dart';
import 'package:holz_logistik/screens/analytics_screen.dart';
import 'package:holz_logistik/screens/home_screen.dart';
import 'package:holz_logistik/screens/map_screen.dart';
import 'package:holz_logistik/screens/settings_screen.dart';
import 'package:holz_logistik/widgets/bottom_navigation.dart';
import 'package:holz_logistik/screens/archive_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showSettings = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const MapScreen(),
      const ArchiveScreen(),
      const AnalyticsScreen()
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SyncService.initializeUser();
      SyncService.syncChanges();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });
  }

/*
  leading: IconButton(
  icon: const Icon(Icons.bug_report),
  onPressed: () async {
  ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Printing database contents to console...')),
  );
  await DatabaseHelper.instance.printDatabaseContents();
  if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Database contents printed to console')),
  );
  }
  },
  tooltip: 'Print Database',
  ),
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holz Logistik'),
        actions: [
          IconButton(
            icon: Icon(_showSettings ? Icons.close : Icons.settings),
            onPressed: _toggleSettings,
          )
        ],
      ),
      body: _showSettings
          ? const SettingsScreen()
          : IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _showSettings = false;
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
