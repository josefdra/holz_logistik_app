// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add this import
import 'package:provider/provider.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/sync_provider.dart'; // Add this import
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
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return; // Check again after async operation

      setState(() {
        _serverUrlController.text = prefs.getString('server_url') ?? '';
        _apiKeyController.text = prefs.getString('api_key') ?? '';
        _driverNameController.text = prefs.getString('driver_name') ?? '';

        // Check if credentials are already set
        _hasCredentials = _serverUrlController.text.isNotEmpty &&
            _apiKeyController.text.isNotEmpty;
      });
    } catch (e) {
      if (!mounted) return; // Check again after potential exception

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Einstellungen: $e')),
      );
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

    // Validate server URL format
    final serverUrl = _serverUrlController.text.trim();
    if (serverUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(serverUrl);
        if (!uri.isAbsolute || (!uri.scheme.startsWith('http'))) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ungültige Server-URL. Beginnen Sie mit http:// oder https://')),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ungültige Server-URL')),
        );
        return;
      }
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

      if (!mounted) return; // Check if widget is still mounted

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert')),
      );

      // Update the credentials state after saving
      setState(() {
        _hasCredentials = _serverUrlController.text.isNotEmpty &&
            _apiKeyController.text.isNotEmpty;
        _showCredentials = false; // Hide credentials after saving
      });

      // Test connection after saving
      if (serverUrl.isNotEmpty && _apiKeyController.text.trim().isNotEmpty) {
        // Store context in a local variable
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);
        final success = await syncProvider.sync();

        if (!mounted) return; // Check if widget is still mounted

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verbindung zum Server erfolgreich')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verbindungsfehler: ${syncProvider.lastError}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e')),
      );
    } finally {
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    if (_serverUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server-URL erforderlich')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String url = _serverUrlController.text.trim();
      // Ensure URL doesn't end with a slash
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      final response = await http.get(
        Uri.parse('$url/api_status.php'),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return; // Check if widget is still mounted

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verbindung erfolgreich: ${response.body}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: Status ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verbindungsfehler: $e')),
      );
    } finally {
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            // Server credentials section
            // Display locked state or entry fields based on state
            if (_hasCredentials && !_showCredentials)
            // Locked state
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
                    ],
                  ),
                ),
              )
            else
            // Edit fields
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

            const SizedBox(height: 16),

            // Test connection button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: const Icon(Icons.wifi),
                label: const Text('Verbindung testen'),
              ),
            ),

            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                child: const Text('Speichern'),
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