import 'package:holz_logistik_backend/repository/repository.dart';

List<String> getSawmillIds(List<Sawmill> sawmills) {
  return sawmills.map((sawmill) => sawmill.id).toList();
}
