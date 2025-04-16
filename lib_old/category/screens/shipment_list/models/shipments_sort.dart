import 'package:holz_logistik_backend/api/shipment_api.dart';

List<Shipment> sortByLastEdit(List<Shipment> shipments) {
  final sortedList = List<Shipment>.from(shipments)
    ..sort(
      (a, b) => b.lastEdit.compareTo(a.lastEdit),
    );
  return sortedList;
}
