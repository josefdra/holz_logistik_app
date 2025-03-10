import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add this import
import 'package:provider/provider.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/data_provider.dart';
import '../providers/sync_provider.dart'; // Add this import
import '../widgets/sync_status.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
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
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _apiKeyController.text = prefs.getString('api_key') ?? '';
      });
    } catch (e) {
      if (!mounted) return;

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
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      if (_apiKeyController.text.trim().isNotEmpty) {
        await prefs.setString('api_key', _apiKeyController.text.trim());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert')),
      );

      setState(() {
        _hasCredentials = _apiKeyController.text.isNotEmpty;
      });
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

  String _maskUrl(String url) {
    if (url.isEmpty) return '';

    try {
      final uri = Uri.parse(url);
      return '${uri.scheme}://${uri.host}/***';
    } catch (e) {
      return '******';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
        builder: (context, dataProvider, child)
    {
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
              // const SyncStatusWidget(),

              const SizedBox(height: 24),

              Text(
                user.name,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              const SizedBox(height: 16),
              const Text('asdf'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'API-Schlüssel',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium,
                  ),
                  if (_hasCredentials)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showCredentials = !_showCredentials;
                        });
                      },
                      child:
                      Text(_showCredentials ? 'Verbergen' : 'Bearbeiten'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_hasCredentials && !_showCredentials)
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
                        Text('Server: ${_maskUrl('url')}'),
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
                  onPressed: _isLoading ? null : _saveSettings,
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
