import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/shipment_repository.dart';

class ShipmentListTile extends StatelessWidget {
  const ShipmentListTile({
    required this.shipment,
    super.key,
    this.onDismissed,
    this.onTap,
  });

  final Shipment shipment;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('shipmentListTile_dismissible_${shipment.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Color(0xAAFFFFFF),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text('${shipment.quantity}'),
        trailing: IconButton(
          onPressed: () => onDismissed?.call(DismissDirection.endToStart),
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
