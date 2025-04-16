import 'package:holz_logistik_backend/api/user_api.dart';

List<User> sortByLastEdit(List<User> users) {
  final sortedList = List<User>.from(users)
    ..sort(
      (a, b) => b.lastEdit.compareTo(a.lastEdit),
    );
  return sortedList;
}
