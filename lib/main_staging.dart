import 'package:flutter/widgets.dart';
import 'package:holz_logistik/bootstrap.dart';
import 'package:users_local_storage/users_local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final usersApi = UsersLocalStorage(
    plugin: await SharedPreferences.getInstance(),
  );

  bootstrap(usersApi: usersApi);
}