import 'package:flutter/material.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/data_list.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back arrow
        title: Text('Holz Logistik'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: DataList(),
      bottomNavigationBar: BottomNavigation(currentIndex: 0),
    );
  }
}
