import 'package:flutter/material.dart';
import 'package:holz_logistik/screens/home_screen.dart';
import 'package:holz_logistik/screens/map_screen.dart';
import 'package:holz_logistik/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/providers/location_provider.dart';
import 'package:holz_logistik/utils/demo_data_generator.dart';
import 'archive_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isDemoMode = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const ArchiveScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LocationProvider>();
      provider.loadLocations();
      provider.loadArchivedLocations();
    });
  }

  Future<void> _toggleDemoMode() async {
    final provider = context.read<LocationProvider>();

    if (!_isDemoMode) {
      // Generate and add demo locations
      final demoLocations = DemoDataGenerator.generateLocations(50);
      for (var location in demoLocations) {
        await provider.addLocation(location);
      }
      setState(() => _isDemoMode = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo-Daten wurden hinzugefügt')),
        );
      }
    } else {
      // Clear all locations
      final locations = provider.locations;
      for (var location in locations) {
        if (location.id != null) {
          await provider.deleteLocation(location.id!);
        }
      }
      setState(() => _isDemoMode = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demo-Daten wurden entfernt')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holz Logistik'),
        actions: [
          // Demo mode toggle button
          IconButton(
            icon: Icon(_isDemoMode ? Icons.toggle_on : Icons.toggle_off),
            onPressed: _toggleDemoMode,
            tooltip: _isDemoMode ? 'Demo-Modus ausschalten' : 'Demo-Modus einschalten',
          ),
        ],
      ),
      body: _screens[_currentIndex],
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