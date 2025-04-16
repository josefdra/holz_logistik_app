import 'package:holz_logistik_backend/api/note_api.dart';

List<Note> sortByLastEdit(List<Note> notes) {
  final sortedList = List<Note>.from(notes)
    ..sort(
      (a, b) => b.lastEdit.compareTo(a.lastEdit),
    );
  return sortedList;
}
