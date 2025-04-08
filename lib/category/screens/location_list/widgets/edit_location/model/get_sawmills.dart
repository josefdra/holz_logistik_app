import 'package:holz_logistik_backend/repository/repository.dart';

List<Sawmill> getSawmills(SawmillRepository repo, List<String>? sawmillIds) {
  if (sawmillIds == null) {
    return [];
  }

  return repo.currentSawmills
      .where((sawmill) => sawmillIds.contains(sawmill.id))
      .toList();
}
