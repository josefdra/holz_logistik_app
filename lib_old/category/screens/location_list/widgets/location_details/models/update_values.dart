import 'package:holz_logistik_backend/repository/repository.dart';

Map<String, dynamic> updateValues(List<Shipment> shipments, Location location) {
  var quantity = location.initialQuantity;
  var oversizeQuantity = location.initialOversizeQuantity;
  var pieceCount = location.initialPieceCount;

  for (final shipment in shipments) {
    quantity -= shipment.quantity;
    oversizeQuantity -= shipment.oversizeQuantity;
    pieceCount -= shipment.pieceCount;
  }

  return {
    'quantity': quantity,
    'oversizeQuantity': oversizeQuantity,
    'pieceCount': pieceCount,
  };
}
