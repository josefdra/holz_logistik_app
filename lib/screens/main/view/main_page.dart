import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/analytics/analytics.dart';
import 'package:holz_logistik/screens/locations/location_list/location_list.dart';
import 'package:holz_logistik/screens/main/main_screen.dart';
import 'package:holz_logistik/screens/map/map.dart';
import 'package:holz_logistik/screens/notes_list/notes_list.dart';
import 'package:holz_logistik/screens/settings/settings.dart';
import 'package:holz_logistik/screens/shipment_list/shipments.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:holz_logistik_backend/sync/sync.dart';

class MainPage extends StatelessWidget {
  const MainPage({required this.coreSyncService, super.key});

  final CoreSyncService coreSyncService;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainBloc(
        authenticationRepository: context.read<AuthenticationRepository>(),
        coreSyncService: coreSyncService,
      )..add(const MainSubscriptionRequested()),
      child: const MainView(),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        if (state.status == MainStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final effectiveIndex = state.isPrivileged
            ? state.selectedTab.index
            : (state.selectedTab.index >= 4 ? 0 : state.selectedTab.index);

        final connectionIcon = _getConnectionIcon(state.connectionStatus);

        final navItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Standorte',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Karte',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'Notizen',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Abfuhren',
          ),
        ];

        if (state.isPrivileged) {
          navItems.add(
            const BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analyse',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Holz Logistik'),
            leading: IconButton(
              onPressed: () =>
                  context.read<MainBloc>().add(const MainConnectPressed()),
              icon: connectionIcon,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.of(context).push(
                  SettingsPage.route(
                    onApiKeyChanged: () =>
                        context.read<MainBloc>().add(const MainApiKeyChanged()),
                  ),
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: effectiveIndex,
            children: [
              const LocationListPage(),
              const MapPage(),
              const NotesListPage(),
              const ShipmentsPage(),
              if (state.isPrivileged) const AnalyticsPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: effectiveIndex,
            onTap: (index) {
              if (index < navItems.length) {
                context
                    .read<MainBloc>()
                    .add(MainTabChanged(MainTab.values[index]));
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF2C5E1A),
            items: navItems,
          ),
        );
      },
    );
  }

  Widget _getConnectionIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return const Icon(
          Icons.cloud_off,
          color: Colors.grey,
        );
      case ConnectionStatus.connecting:
        return const Icon(
          Icons.cloud_sync,
          color: Colors.orange,
        );
      case ConnectionStatus.connected:
        return const Icon(
          Icons.sync,
          color: Colors.blue,
        );
      case ConnectionStatus.synced:
        return const Icon(
          Icons.cloud_done,
          color: Colors.green,
        );
      case ConnectionStatus.reconnecting:
        return const Icon(
          Icons.sync_problem,
          color: Colors.blue,
        );
      case ConnectionStatus.error:
        return const Icon(
          Icons.error_outline,
          color: Colors.red,
        );
    }
  }
}
