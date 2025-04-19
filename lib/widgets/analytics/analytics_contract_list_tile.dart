import 'package:flutter/material.dart';
import 'package:holz_logistik/models/general/color.dart';
import 'package:holz_logistik_backend/api/contract_api.dart';

class AnalyticsContractListTile extends StatelessWidget {
  const AnalyticsContractListTile({
    required this.contract,
    super.key,
  });

  final Contract contract;

  @override
  Widget build(BuildContext context) {
    final restQuantity = contract.availableQuantity - contract.bookedQuantity;

    final maxValue = contract.availableQuantity;
    final bookedPercentage =
        maxValue > 0 ? (contract.bookedQuantity / maxValue) : 1.0;
    final shippedPercentage = maxValue > 0
        ? (contract.shippedQuantity / maxValue)
        : (contract.shippedQuantity / contract.bookedQuantity);

    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              contract.title,
              textAlign: TextAlign.start,
            ),
          ),
          Container(width: 70, height: 5, color: colorFromString(contract.id)),
          Expanded(
            child: Text(
              '${contract.availableQuantity} fm',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                ),
                FractionallySizedBox(
                  widthFactor: bookedPercentage > 1 ? 1 : bookedPercentage,
                  heightFactor: 1,
                  child: Container(
                    color: const Color.fromARGB(255, 194, 218, 135),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: shippedPercentage > 1 ? 1 : shippedPercentage,
                  heightFactor: 1,
                  child: Container(
                    color: const Color.fromARGB(255, 69, 131, 46),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                      text: 'Gebucht: ${contract.bookedQuantity} fm',
                      color: const Color.fromARGB(255, 69, 131, 46),
                    ),
                    _buildLegendItem(
                      text: 'Verfügbar: $restQuantity fm',
                      color: Colors.grey.shade100,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    text: 'Abgefahren: ${contract.shippedQuantity} fm',
                    color: const Color.fromARGB(255, 194, 218, 135),
                  ),
                  const SizedBox(height: 17),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required String text, Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (color == null)
          const SizedBox(width: 16, height: 12)
        else
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
