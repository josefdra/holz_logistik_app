import 'package:flutter/widgets.dart';
import 'package:holz_logistik/bootstrap.dart';
import 'package:users_database_service/users_database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final usersApi = UsersDatabaseService();

  bootstrap(usersApi: usersApi);
}
