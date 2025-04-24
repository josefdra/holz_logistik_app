import 'package:flutter/material.dart';
import 'package:holz_logistik/models/general/color.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class ContractListTile extends StatelessWidget {
  const ContractListTile({
    required this.contract,
    super.key,
    this.onTap,
    this.onReactivate,
  });

  final Contract contract;
  final VoidCallback? onTap;
  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(width: 15, color: colorFromString(contract.name)),
      onTap: onTap,
      title: Text(contract.title),
      subtitle: Text(contract.additionalInfo),
      trailing: contract.done
          ? IconButton(
              onPressed: () => onReactivate?.call(),
              icon: const Icon(Icons.publish),
            )
          : null,
    );
  }
}
