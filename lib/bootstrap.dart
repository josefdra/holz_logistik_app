import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:holz_logistik/app/app.dart';
import 'package:holz_logistik/app/app_bloc_observer.dart';
import 'package:user_api/user_api.dart';
import 'package:user_repository/user_repository.dart';
import 'package:user_sync_service/user_sync_service.dart';

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
