import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/app/app.dart';
import 'package:holz_logistik/app/app_bloc_observer.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';
import 'package:holz_logistik_backend/sync/user_sync_service.dart';

void bootstrap({
  required UserApi userApi,
  required UserSyncService userSyncService,
}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log(error.toString(), stackTrace: stack);
    return true;
  };

  Bloc.observer = const AppBlocObserver();

  runApp(
    App(
      createUserRepository: () => UserRepository(
        userApi: userApi,
        userSyncService: userSyncService,
      ),
    ),
  );
}
