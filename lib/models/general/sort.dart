import 'package:holz_logistik_backend/general/general.dart';

List<T> sortByDate<T extends Gettable>(List<T> items) {
  final sortedList = List<T>.from(items)
    ..sort(
      (a, b) => b.date.compareTo(a.date),
    );
  return sortedList;
}

List<T> sortByName<T extends Gettable>(List<T> items) {
  final sortedList = List<T>.from(items)
    ..sort(
      (a, b) => b.name.compareTo(a.name),
    );
  return sortedList;
}
