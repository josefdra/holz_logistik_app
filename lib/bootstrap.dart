import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:holz_logistik/app/app.dart';
import 'package:holz_logistik/app/app_bloc_observer.dart';
import 'package:users_api/users_api.dart';
import 'package:users_repository/users_repository.dart';

void bootstrap({required UsersApi usersApi}) {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log(error.toString(), stackTrace: stack);
    return true;
  };

  Bloc.observer = const AppBlocObserver();

  runApp(App(createUsersRepository: () => UsersRepository(usersApi: usersApi)));
}