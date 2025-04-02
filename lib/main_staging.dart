import 'package:core_local_storage/core_local_storage.dart';
import 'package:core_sync_service/core_sync_service.dart';
import 'package:flutter/widgets.dart';
import 'package:holz_logistik/bootstrap.dart';
import 'package:user_local_storage/user_local_storage.dart';
import 'package:user_sync_service/user_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const url = 'ws://localhost:8080/ws';

  final coreLocalStorage = CoreLocalStorage();
  final userApi =
      UserLocalStorage(coreLocalStorage: coreLocalStorage);
  final coreSyncService = CoreSyncService(url: url);
  final userSyncService = UserSyncService(coreSyncService: coreSyncService);

  bootstrap(userApi: userApi, userSyncService: userSyncService);
}
