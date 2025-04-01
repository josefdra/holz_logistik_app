import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/home/home.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:holz_logistik/theme/theme.dart';
import 'package:users_repository/users_repository.dart';

class App extends StatelessWidget {
  const App({required this.createUsersRepository, super.key});

  final UsersRepository Function() createUsersRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UsersRepository>(
      create: (_) => createUsersRepository(),
      dispose: (repository) => repository.dispose(),
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlutterUsersTheme.light,
      darkTheme: FlutterUsersTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
