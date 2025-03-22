import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:holz_logistik/utils/data_provider.dart';
import 'package:holz_logistik/utils/sync_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _showCredentials = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_apiKeyController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'API-Schlüssel ist erforderlich';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showCredentials = false;
      _errorMessage = '';
    });

    try {
      final apiKey = _apiKeyController.text.trim();
      final userData = await SyncService.getUserData(apiKey);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiKey', apiKey);

      final name = userData['name'] ?? 'Unknown';
      final username = userData['username'] ?? 'Unknown';

      await prefs.setString('name', name);
      await prefs.setString('username', username);

      if (!mounted) return;

      SyncService.updateUserData(name, apiKey);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert')),
      );

      setState(() {
        _showCredentials = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Fehler: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(builder: (context, dataProvider, child) {
      if (dataProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SyncService.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'API-Schlüssel',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (SyncService.hasCredentials)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCredentials = !_showCredentials;
                      });
                    },
                    child: Text(_showCredentials ? 'Verbergen' : 'Bearbeiten'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (SyncService.hasCredentials && !_showCredentials)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_outline),
                          SizedBox(width: 8),
                          Text(
                            'Server-Verbindung konfiguriert',
                            style:
                            TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API-Schlüssel',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            if (_showCredentials || !SyncService.hasCredentials) SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Speichern'),
              ),
            )
          ],
        ),
      );
    });
  }
}