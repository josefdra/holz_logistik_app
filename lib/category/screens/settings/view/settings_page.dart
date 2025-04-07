import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/admin/user/user_list/view/view.dart';
import 'package:holz_logistik/category/core/authentication/bloc/authentication_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/settings/settings.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';
import 'package:holz_logistik_backend/repository/src_authentication/authentication_repository.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route({Contract? initialContract}) {
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

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAppBarTitle),
        actions: [
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state.status == AuthenticationStatus.admin) {
                return IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () =>
                      Navigator.of(context).push(UserListPage.route()),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == SettingsStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.contractListErrorSnackbarText),
                    ),
                  );
              }
            },
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state.status == SettingsStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state.status != SettingsStatus.success) {
              return const SizedBox();
            }

            return Column(
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
                    onPressed: () {
                      context.read<AuthenticationBloc>().add(
                            AuthenticationVerificationRequested(state.apiKey),
                          );
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.settingsSaveButtonText),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
