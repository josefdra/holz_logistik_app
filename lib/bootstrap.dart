import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:holz_logistik/app/app.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/sync/core_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void bootstrap(SharedPreferences sharedPrefs) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log(error.toString(), stackTrace: stack);
    return true;
  };

  const url = 'ws://localhost:8080';

  // Bloc.observer = const AppBlocObserver();
  final coreLocalStorage = CoreLocalStorage();
  final coreSyncService = CoreSyncService(url: url);

  runApp(
    App(
      sharedPrefs: sharedPrefs,
      coreLocalStorage: coreLocalStorage,
      coreSyncService: coreSyncService,
    ),
  );
}
