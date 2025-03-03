import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Liste',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Karte',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.archive),
          label: 'Archiv',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Einstellungen',
        ),
      ],
    );
  }
}