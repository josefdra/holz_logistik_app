import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class ContractListTile extends StatelessWidget {
  const ContractListTile({
    required this.contract,
    super.key,
    this.onTap,
  });

  final Contract contract;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(contract.title),
      subtitle: Text(contract.additionalInfo),
    );
  }
}
