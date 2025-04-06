import 'package:holz_logistik_backend/api/location_api.dart';

List<Location> sortByLastEdit(List<Location> locations) {
  final sortedList = List<Location>.from(locations)
    ..sort(
      (a, b) => b.lastEdit.compareTo(a.lastEdit),
    );
  return sortedList;
}
