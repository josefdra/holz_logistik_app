import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class ShipmentListTile extends StatelessWidget {
  ShipmentListTile({
    required this.shipment,
    required String userName,
    required this.sawmillName,
    super.key,
    this.onDeleted,
  }) : userName = userName.split(' ');

  final Shipment shipment;
  final List<String> userName;
  final String sawmillName;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('${shipment.lastEdit.day}.${shipment.lastEdit.month}.'),
            Text(userName[0]),
            Text(userName[1]),
          ],
        ),
      ),
      title: Text(sawmillName),
      subtitle:
          Text('${shipment.quantity} fm, ÜS: ${shipment.oversizeQuantity} fm, '
              '${shipment.pieceCount} Stk'),
      trailing: IconButton(
        onPressed: () => onDeleted?.call(),
        icon: const Icon(Icons.undo),
      ),
    );
  }
}
