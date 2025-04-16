import 'package:holz_logistik_backend/api/contract_api.dart';

List<Contract> sortByLastEdit(List<Contract> contracts) {
  final sortedList = List<Contract>.from(contracts)
    ..sort(
      (a, b) => b.lastEdit.compareTo(a.lastEdit),
    );
  return sortedList;
}
