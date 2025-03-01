// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:holz_logistik/screens/home_screen.dart';
import 'package:holz_logistik/screens/map_screen.dart';
import 'package:holz_logistik/screens/settings_screen.dart'; // New import
import 'package:holz_logistik/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/providers/location_provider.dart';
import 'package:holz_logistik/providers/sync_provider.dart'; // New import
import 'archive_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Create persistent screen instances to maintain their state
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens
    _screens = [
      const HomeScreen(),
      const MapScreen(),
      const ArchiveScreen(),
      const SettingsScreen(), // New settings screen
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();
      locationProvider.loadLocations();
      locationProvider.loadArchivedLocations();

      // Initial sync when app starts
      final syncProvider = context.read<SyncProvider>();
      syncProvider.sync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holz Logistik'),
        actions: [
          // Show sync status indicator in app bar
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              Widget icon;

              switch (syncProvider.status) {
                case SyncStatus.syncing:
                  icon = const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                  break;
                case SyncStatus.error:
                  icon = const Icon(Icons.sync_problem, color: Colors.amber);
                  break;
                case SyncStatus.offline:
                  icon = const Icon(Icons.cloud_off, color: Colors.grey);
                  break;
                case SyncStatus.complete:
                  icon = const Icon(Icons.cloud_done, color: Colors.white);
                  break;
                case SyncStatus.idle:
                icon = const Icon(Icons.cloud_queue, color: Colors.white);
                  break;
              }

              return IconButton(
                icon: icon,
                onPressed: () {
                  // Navigate to settings screen when sync icon is pressed
                  setState(() {
                    _currentIndex = 3; // Index of settings screen
                  });
                },
                tooltip: 'Synchronisierungsstatus',
              );
            },
          ),
        ],
      ),
      // Use IndexedStack to maintain the state of all screens
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}