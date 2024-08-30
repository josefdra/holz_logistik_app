import 'package:flutter/material.dart';
import 'package:holz_logistik/services/auth_service.dart';
import 'package:holz_logistik/utils/offline_sync_manager.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final offlineSyncManager = Provider.of<OfflineSyncManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.sync),
            title: Text('Sync Offline Data'),
            onTap: () async {
              try {
                await offlineSyncManager.syncOfflineData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Offline data synced successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Failed to sync offline data: ${e.toString()}')),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await authService.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
