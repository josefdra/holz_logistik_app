import 'package:flutter/material.dart';
import 'package:holz_logistik/models/analytics/analytics.dart';

class AnalyticsListTile extends StatelessWidget {
  const AnalyticsListTile({
    required this.data,
    super.key,
    this.onTap,
    this.onReactivate,
  });

  final AnalyticsDataElement data;
  final VoidCallback? onTap;
  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(data.sawmillName),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Menge: ${data.quantity} fm'),
          Text('Davon ÜS: ${data.oversizeQuantity} fm'),
          Text('Stückzahl: ${data.pieceCount} Stk'),
        ],
      ),
    );
  }
}
