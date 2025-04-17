import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:holz_logistik/screens/settings/settings.dart';
import 'package:holz_logistik/screens/users/user_list/user_list.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/repository/authentication_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => SettingsBloc(
          authenticationRepository: context.read<AuthenticationRepository>(),
        ),
        child: const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(
        authenticationRepository: context.read<AuthenticationRepository>(),
      )..add(const SettingsSubscriptionRequested()),
      child: const SettingsWidget(),
    );
  }
}

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({required this.body, super.key, this.admin = false});

  final Widget body;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAppBarTitle),
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
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.authenticatedUser.name == '')
                Center(
                  child: Text(
                    l10n.settingsNotAuthenticatedText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                Center(
                  child: Text(
                    state.authenticatedUser.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              const SizedBox(height: 32),
              TextFormField(
                key: const Key('settingsPage_apiKey_textFormField'),
                initialValue: '',
                decoration: InputDecoration(
                  labelText: l10n.settingsApiKeyLabel,
                ),
                maxLength: 50,
                onChanged: (value) {
                  context
                      .read<SettingsBloc>()
                      .add(SettingsApiKeyChanged(value));
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => context.read<SettingsBloc>().add(
                        const SettingsAuthenticationVerificationRequested(),
                      ),
                  child: Text(l10n.settingsSaveButtonText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
