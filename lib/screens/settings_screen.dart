// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sync_status.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _driverNameController = TextEditingController();
  bool _isLoading = true;
  bool _hasCredentials = false;
  bool _showCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _apiKeyController.dispose();
    _driverNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      _serverUrlController.text = prefs.getString('server_url') ?? '';
      _apiKeyController.text = prefs.getString('api_key') ?? '';
      _driverNameController.text = prefs.getString('driver_name') ?? '';

      // Check if credentials are already set
      _hasCredentials = _serverUrlController.text.isNotEmpty &&
          _apiKeyController.text.isNotEmpty;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Einstellungen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    // Validate driver name is provided
    if (_driverNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte geben Sie einen Fahrernamen ein')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Only save server URL and API key if they are provided
      if (_serverUrlController.text.trim().isNotEmpty) {
        await prefs.setString('server_url', _serverUrlController.text.trim());
      }

      if (_apiKeyController.text.trim().isNotEmpty) {
        await prefs.setString('api_key', _apiKeyController.text.trim());
      }

      // Always save driver name
      await prefs.setString('driver_name', _driverNameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einstellungen gespeichert')),
        );

        // Update the credentials state after saving
        setState(() {
          _hasCredentials = _serverUrlController.text.isNotEmpty &&
              _apiKeyController.text.isNotEmpty;
          _showCredentials = false; // Hide credentials after saving
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetCredentials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zugangsdaten zurücksetzen'),
        content: const Text(
            'Möchten Sie die Server-URL und den API-Schlüssel wirklich zurücksetzen? '
                'Diese Aktion kann nicht rückgängig gemacht werden.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _serverUrlController.text = '';
        _apiKeyController.text = '';
        _hasCredentials = false;
        _showCredentials = true;
      });

      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('server_url');
      await prefs.remove('api_key');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zugangsdaten wurden zurückgesetzt')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync status card
            const SyncStatusWidget(),

            const SizedBox(height: 24),

            // Driver name field - always visible
            Text(
              'Fahrer Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _driverNameController,
              decoration: const InputDecoration(
                labelText: 'Fahrername',
                hintText: 'Bitte geben Sie Ihren Namen ein',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Server settings section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Server-Einstellungen',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_hasCredentials)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCredentials = !_showCredentials;
                      });
                    },
                    child: Text(_showCredentials ? 'Verbergen' : 'Anzeigen'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (_hasCredentials && !_showCredentials)
            // Display locked state with summary when credentials are hidden
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock_outline),
                          SizedBox(width: 8),
                          Text(
                            'Server-Verbindung konfiguriert',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Server: ${_maskUrl(_serverUrlController.text)}'),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _resetCredentials,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Zugangsdaten zurücksetzen'),
                      ),
                    ],
                  ),
                ),
              )
            else
            // Show credential input fields when either no credentials set or viewing is enabled
              Column(
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _serverUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'https://your-server.com/api',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API-Schlüssel',
                      helperText: 'Ihr persönlicher Zugangscode',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ],
              ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Speichern'),
              ),
            ),

            const SizedBox(height: 32),

            // App information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Holz Logistik App'),
                    const Text('Version 1.1.0'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to mask URL for display
  String _maskUrl(String url) {
    if (url.isEmpty) return '';

    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}/***';
    } catch (e) {
      // If URL parsing fails, just show a generic mask
      return '******';
    }
  }
}