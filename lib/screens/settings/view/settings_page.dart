import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/settings/settings.dart';
import 'package:holz_logistik/screens/users/user_list/user_list.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/repository/authentication_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({this.onApiKeyChanged, super.key});

  final VoidCallback? onApiKeyChanged;

  static Route<void> route({VoidCallback? onApiKeyChanged}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => SettingsBloc(
          authenticationRepository: context.read<AuthenticationRepository>(),
          onApiKeyChanged: onApiKeyChanged,
        )..add(const SettingsSubscriptionRequested()),
        child: SettingsPage(onApiKeyChanged: onApiKeyChanged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
        authenticationRepository: context.read<AuthenticationRepository>(),
        onApiKeyChanged: onApiKeyChanged,
      )..add(const SettingsSubscriptionRequested()),
      child: SettingsWidget(onApiKeyChanged: onApiKeyChanged),
    );
  }
}

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({required this.body, super.key, this.admin = false});

  final Widget body;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        actions: [
          if (admin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.of(context).push(UserListPage.route()),
            ),
        ],
      ),
      body: body,
    );
  }
}

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key, this.onApiKeyChanged});

  final VoidCallback? onApiKeyChanged;

  void _showApiKeyDialog(BuildContext context) {
    final apiKeyController = TextEditingController();

    showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: SizedBox(
            width: 300,
            child: TextFormField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Geben Sie Ihren API Key ein',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (apiKeyController.text.isNotEmpty) {
                      context
                          .read<SettingsBloc>()
                          .add(SettingsApiKeyChanged(apiKeyController.text));
                      context.read<SettingsBloc>().add(
                            const SettingsAuthenticationVerificationRequested(),
                          );
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Speichern'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildDatabaseList(BuildContext context, SettingsState state) {
    return FutureBuilder<List<String>>(
      future: context.read<AuthenticationRepository>().databaseList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Keine Datenbanken verfügbar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        final databases = snapshot.data!;

        return FutureBuilder<String>(
          future: context.read<AuthenticationRepository>().activeDb,
          builder: (context, activeDbSnapshot) {
            final activeDb = activeDbSnapshot.data ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Verfügbare Datenbanken:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: databases.map((database) {
                      final isActive = database == activeDb;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<SettingsBloc>()
                                .add(SettingsDatabaseChanged(database));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            foregroundColor: isActive
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            elevation: isActive ? 4 : 1,
                            side: BorderSide(
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              width: isActive ? 2 : 1,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _capitalizeFirst(database),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isActive)
                                Icon(
                                  Icons.check_circle,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state.status == SettingsStatus.loading) {
          return const CustomScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state.status != SettingsStatus.success) {
          return const CustomScaffold(body: SizedBox());
        }

        return CustomScaffold(
          admin: state.authenticatedUser.role == Role.admin,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: state.authenticatedUser.name == ''
                      ? Center(
                          child: Text(
                            'Nicht angemeldet',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        )
                      : Center(
                          child: Text(
                            state.authenticatedUser.name,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                ),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApiKeyDialog(context),
                    icon: const Icon(Icons.key),
                    label: const Text('Datenbank hinzufügen'),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDatabaseList(context, state),
              ],
            ),
          ),
        );
      },
    );
  }
}
