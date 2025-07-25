import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/main/view/main_page.dart';
import 'package:holz_logistik_backend/api/api.dart';
import 'package:holz_logistik_backend/local_storage/local_storage.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:holz_logistik_backend/sync/sync.dart';

class App extends StatelessWidget {
  App({
    required this.coreLocalStorage,
    required this.coreSyncService,
    super.key,
  })  : authenticationApi =
            AuthenticationLocalStorage(coreLocalStorage: coreLocalStorage),
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
      child: AppView(coreSyncService: coreSyncService),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({required this.coreSyncService, super.key});

  final CoreSyncService coreSyncService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holz Logistik App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C5E1A),
          primary: const Color(0xFF2C5E1A),
          secondary: Colors.white,
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
      home: MainPage(coreSyncService: coreSyncService),
    );
  }
}
