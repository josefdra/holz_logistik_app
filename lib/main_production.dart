import 'package:flutter/widgets.dart';
import 'package:holz_logistik/bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPrefs = await SharedPreferences.getInstance();

  bootstrap(sharedPrefs);
}
