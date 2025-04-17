import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/shipment_repository.dart';

class ShipmentListTile extends StatelessWidget {
  const ShipmentListTile({
    required this.shipment,
    super.key,
    this.onDeleted,
    this.onTap,
  });

  final Shipment shipment;
  final VoidCallback? onDeleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text('${shipment.quantity}'),
      trailing: IconButton(
        onPressed: () => onDeleted?.call(),
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}
