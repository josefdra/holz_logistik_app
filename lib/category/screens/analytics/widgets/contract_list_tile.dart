import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class ContractListTile extends StatelessWidget {
  const ContractListTile({
    required this.contract,
    super.key,
    this.onDismissed,
    this.onTap,
  });

  final Contract contract;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('contractListTile_dismissible_${contract.id}'),
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
        title: Text(contract.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verfügbare Menge: ${contract.availableQuantity} fm'),
            Text('Davon zugewiesen: ${contract.bookedQuantity} fm'),
            Text('Davon abgefahren: ${contract.shippedQuantity} fm'),
          ],
        ),
        trailing: IconButton(
          onPressed: () => onDismissed?.call(DismissDirection.endToStart),
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
