import 'package:core_database_service/core_database_service.dart';
import 'package:core_sync_service/core_sync_service.dart';
import 'package:flutter/widgets.dart';
import 'package:holz_logistik/bootstrap.dart';
import 'package:user_database_service/user_database_service.dart';
import 'package:user_sync_service/user_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const url = 'ws://localhost:8080/ws';

  final coreDatabaseService = CoreDatabaseService();
  final userApi =
      UserDatabaseService(coreDatabaseService: coreDatabaseService);
  final coreSyncService = CoreSyncService(url: url);
  final userSyncService = UserSyncService(coreSyncService: coreSyncService);

  bootstrap(userApi: userApi, userSyncService: userSyncService);
}
