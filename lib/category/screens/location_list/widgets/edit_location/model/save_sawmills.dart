import 'package:holz_logistik_backend/repository/repository.dart';

List<String> saveSawmills(SawmillRepository repo, List<Sawmill> sawmills) {
  for (final sawmill in sawmills) {
    repo.saveSawmill(sawmill);
  }

  return sawmills.map((sawmill) => sawmill.id).toList();
}
