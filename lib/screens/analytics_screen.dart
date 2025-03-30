import 'package:flutter/material.dart';

import 'package:holz_logistik/data/database_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreen();
}

class _AnalyticsScreen extends State<AnalyticsScreen> {
  static final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Kommt bald")
    );
  }
}
