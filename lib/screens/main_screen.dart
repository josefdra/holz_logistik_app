import 'package:flutter/material.dart';
import 'package:holz_logistik/screens/home_screen.dart';
import 'package:holz_logistik/screens/map_screen.dart';
import 'package:holz_logistik/screens/settings_screen.dart';
import 'package:holz_logistik/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/providers/data_provider.dart';
import 'package:holz_logistik/providers/sync_provider.dart';
import 'archive_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const MapScreen(),
      const ArchiveScreen(),
      const SettingsScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = context.read<DataProvider>();
      dataProvider.loadLocations();
      dataProvider.loadArchivedLocations();
      // final syncProvider = context.read<SyncProvider>();
      // syncProvider.sync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holz Logistik'),
        actions: const [
          /*
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
                  setState(() {
                    _currentIndex = 3;
                  });
                },
                tooltip: 'Synchronisierungsstatus',
              );
            },
          ),
           */
        ],
      ),
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
