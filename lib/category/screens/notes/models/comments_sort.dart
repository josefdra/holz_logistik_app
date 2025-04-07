import 'package:holz_logistik_backend/api/comment_api.dart';

List<Comment> sortByLastEdit(List<Comment> comments) {
  final sortedList = List<Comment>.from(comments)
    ..sort(
      (a, b) => b.lastEdit.compareTo(a.lastEdit),
    );
  return sortedList;
}
