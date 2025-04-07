import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/admin/user/user_list/bloc/user_list_bloc.dart';
import 'package:holz_logistik/category/core/authentication/bloc/authentication_bloc.dart';
import 'package:holz_logistik/category/core/home/view/home_page.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/analytics/analytics.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik_backend/api/authentication_api.dart';
import 'package:holz_logistik_backend/api/contract_api.dart';
import 'package:holz_logistik_backend/api/src_location/location_api.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/local_storage/authentication_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/contract_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/src_location/location_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/user_local_storage.dart';
import 'package:holz_logistik_backend/repository/authentication_repository.dart';
import 'package:holz_logistik_backend/repository/src_contract/contract_repository.dart';
import 'package:holz_logistik_backend/repository/src_location/location_repository.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';
import 'package:holz_logistik_backend/sync/authentication_sync_service.dart';
import 'package:holz_logistik_backend/sync/contract_sync_service.dart';
import 'package:holz_logistik_backend/sync/core_sync_service.dart';
import 'package:holz_logistik_backend/sync/location_sync_service.dart';
import 'package:holz_logistik_backend/sync/user_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  App({
    required SharedPreferences sharedPrefs,
    required this.coreLocalStorage,
    required this.coreSyncService,
    super.key,
  })  : authenticationApi = AuthenticationLocalStorage(plugin: sharedPrefs),
        contractApi = ContractLocalStorage(coreLocalStorage: coreLocalStorage),
        locationApi = LocationLocalStorage(coreLocalStorage: coreLocalStorage),
        userApi = UserLocalStorage(coreLocalStorage: coreLocalStorage);

  final CoreLocalStorage coreLocalStorage;
  final CoreSyncService coreSyncService;
  final AuthenticationApi authenticationApi;
  final ContractApi contractApi;
  final LocationApi locationApi;
  final UserApi userApi;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => AuthenticationRepository(
            authenticationApi: authenticationApi,
            authenticationSyncService:
                AuthenticationSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
        ),
        RepositoryProvider(
          create: (_) => ContractRepository(
            contractApi: contractApi,
            contractSyncService:
                ContractSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
        ),
        RepositoryProvider(
          create: (_) => LocationRepository(
            locationApi: locationApi,
            locationSyncService:
                LocationSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
        ),
        RepositoryProvider(
          create: (_) => UserRepository(
            userApi: userApi,
            userSyncService: UserSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) => AuthenticationBloc(
              authenticationRepository:
                  context.read<AuthenticationRepository>(),
            )..add(AuthenticationSubscriptionRequested()),
            child: const AppView(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => AnalyticsBloc(
              contractRepository: context.read<ContractRepository>(),
            )..add(const AnalyticsSubscriptionRequested()),
            child: const AppView(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => LocationListBloc(
              locationRepository: context.read<LocationRepository>(),
            )..add(const LocationListSubscriptionRequested()),
            child: const AppView(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => UserListBloc(
              userRepository: context.read<UserRepository>(),
            )..add(const UserListSubscriptionRequested()),
            child: const AppView(),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holz Logistik App',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C5E1A),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2C5E1A),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}
