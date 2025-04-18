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

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainCubit(),
      child: const MainView(),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((MainCubit cubit) => cubit.state.tab);

    return StreamBuilder<User>(
      stream: context.read<AuthenticationRepository>().authenticatedUser,
      builder: (context, snapshot) {
        final isPrivileged = snapshot.data?.role.isPrivileged ?? false;

        final effectiveIndex = isPrivileged
            ? selectedTab.index
            : (selectedTab.index >= 4 ? 0 : selectedTab.index);

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

        if (isPrivileged) {
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
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () =>
                    Navigator.of(context).push(SettingsPage.route()),
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
              if (isPrivileged) const AnalyticsPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: effectiveIndex,
            onTap: (index) {
              if (index < navItems.length) {
                context.read<MainCubit>().setTab(MainTab.values[index]);
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
}
