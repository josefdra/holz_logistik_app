import 'package:flutter/material.dart';
import 'package:holz_logistik/screens/home_screen.dart';
import 'package:holz_logistik/screens/map_screen.dart';
import 'package:holz_logistik/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/providers/location_provider.dart';
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
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LocationProvider>();
      provider.loadLocations();
      provider.loadArchivedLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holz Logistik'),
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