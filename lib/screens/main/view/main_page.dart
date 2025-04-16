import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../main_screen.dart';
import '../../../../lib_old/category/screens/analytics/analytics.dart';
import '../../../../lib_old/category/screens/location_list/view/view.dart';
import '../../../../lib_old/category/screens/map/map.dart';
import '../../../../lib_old/category/screens/notes/notes.dart';
import '../../../../lib_old/category/screens/settings/view/settings_page.dart';
import '../../../../lib_old/category/screens/shipment_list/view/view.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Holz Logistik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(SettingsPage.route()),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedTab.index,
        children: const [
          LocationListPage(),
          MapPage(),
          NotesPage(),
          ShipmentsPage(),
          AnalyticsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab.index,
        onTap: (index) =>
            {context.read<MainCubit>().setTab(MainTab.values[index])},
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2C5E1A),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Standorte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Karte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'Notizen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Abfuhren',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analyse',
          ),
        ],
      ),
    );
  }
}
