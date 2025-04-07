import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: Scaffold(
        body: const SettingsWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          heroTag: 'settingsPageFloatingActionButton',
          shape: const CircleBorder(),
          onPressed: () => Navigator.of(context).push(
            EditContractWidget.route(),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen: (previous, current) => previous.status != current.status,
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
          if (state.authenticatedUser.name == '') {
            if (state.status == SettingsStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state.status != SettingsStatus.success) {
              return const SizedBox();
            } else {
              return Center(
                child: Text(
                  l10n.settingsNotAuthenticatedText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
          }

          return Center(
            child: Text(
              state.authenticatedUser.name,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          );
        },
      ),
    );
  }
}
