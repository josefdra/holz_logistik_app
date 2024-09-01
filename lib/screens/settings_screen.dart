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
        title: Text('Einstellungen'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.sync),
            title: Text('Offline Daten synchronisieren'),
            onTap: () async {
              try {
                await offlineSyncManager.syncOfflineData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Synchronisieren der offline Daten erfolgreich')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Synchronisieren der offline Daten fehlgeschlagen: ${e.toString()}')),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Ausloggen'),
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
