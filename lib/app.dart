import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/admin/user/user_list/bloc/user_list_bloc.dart';
import 'package:holz_logistik/category/core/authentication/bloc/authentication_bloc.dart';
import 'package:holz_logistik/category/core/home/view/home_page.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/analytics/analytics.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik_backend/api/api.dart';
import 'package:holz_logistik_backend/local_storage/local_storage.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:holz_logistik_backend/sync/sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  App({
    required SharedPreferences sharedPrefs,
    required this.coreLocalStorage,
    required this.coreSyncService,
    super.key,
  })  : authenticationApi = AuthenticationLocalStorage(plugin: sharedPrefs),
        commentApi = CommentLocalStorage(coreLocalStorage: coreLocalStorage),
        contractApi = ContractLocalStorage(coreLocalStorage: coreLocalStorage),
        locationApi = LocationLocalStorage(coreLocalStorage: coreLocalStorage),
        noteApi = NoteLocalStorage(coreLocalStorage: coreLocalStorage),
        photoApi = PhotoLocalStorage(coreLocalStorage: coreLocalStorage),
        sawmillApi = SawmillLocalStorage(coreLocalStorage: coreLocalStorage),
        shipmentApi = ShipmentLocalStorage(coreLocalStorage: coreLocalStorage),
        userApi = UserLocalStorage(coreLocalStorage: coreLocalStorage);

  final CoreLocalStorage coreLocalStorage;
  final CoreSyncService coreSyncService;
  final AuthenticationApi authenticationApi;
  final CommentApi commentApi;
  final ContractApi contractApi;
  final LocationApi locationApi;
  final NoteApi noteApi;
  final PhotoApi photoApi;
  final SawmillApi sawmillApi;
  final ShipmentApi shipmentApi;
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
          lazy: false,
        ),
        RepositoryProvider(
          create: (_) => CommentRepository(
            commentApi: commentApi,
            commentSyncService:
                CommentSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
          lazy: false,
        ),
        RepositoryProvider(
          create: (_) => ContractRepository(
            contractApi: contractApi,
            contractSyncService:
                ContractSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
          lazy: false,
        ),
        RepositoryProvider(
          create: (_) => LocationRepository(
            locationApi: locationApi,
            locationSyncService:
                LocationSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
          lazy: false,
        ),
        RepositoryProvider(
          create: (_) => NoteRepository(
            noteApi: noteApi,
            noteSyncService: NoteSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
          lazy: false,
        ),
        RepositoryProvider(
          create: (_) => PhotoRepository(
            photoApi: photoApi,
            photoSyncService:
                PhotoSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
          lazy: false,
        ),
        RepositoryProvider(
          create: (_) => SawmillRepository(
            sawmillApi: sawmillApi,
            sawmillSyncService:
                SawmillSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
          lazy: false,
        ),
        RepositoryProvider(
          create: (_) => ShipmentRepository(
            shipmentApi: shipmentApi,
            shipmentSyncService:
                ShipmentSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
          lazy: false,
        ),
        RepositoryProvider(
          create: (_) => UserRepository(
            userApi: userApi,
            userSyncService: UserSyncService(coreSyncService: coreSyncService),
          ),
          dispose: (repository) => repository.dispose(),
          lazy: false,
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
              shipmentRepository: context.read<ShipmentRepository>(),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C5E1A),
          primary: const Color(0xFF2C5E1A),
        ),
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
