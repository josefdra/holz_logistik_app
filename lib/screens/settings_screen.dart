import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/data_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _showCredentials = false;

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
    setState(() {
      _isLoading = true;
      _showCredentials = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      if (_apiKeyController.text.trim().isNotEmpty) {
        await prefs.setInt('apiKey', int.parse(_apiKeyController.text.trim()));
      }

      if (!mounted) return;

      // TODO: Get User data from server
      // getUserData from server database server database url is in .env 'BASE_URL'

      // await prefs.setString('name', name);
      // await prefs.setString('username', username);

      // Set user.hasCredentials = true

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert')),
      );
    } catch (e) {
      if (!mounted) return;

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
      final user = dataProvider.user;

      return Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
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
                        if (user.hasCredentials)
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
                    if (user.hasCredentials && !_showCredentials)
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
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API-Schlüssel',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        child: const Text('Speichern'),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}
