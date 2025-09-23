import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:holz_logistik/app.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/sync/core_sync_service.dart';

void bootstrap() {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log(error.toString(), stackTrace: stack);
    return true;
  };

  const url = 'ws://217.154.70.67:3000/ws';
  final coreLocalStorage = CoreLocalStorage();
  final coreSyncService = CoreSyncService(url: url);

  runApp(
    App(
      coreLocalStorage: coreLocalStorage,
      coreSyncService: coreSyncService,
    ),
  );
}
