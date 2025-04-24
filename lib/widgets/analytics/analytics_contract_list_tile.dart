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

    // Safely calculate percentages to avoid negative or invalid values
    final maxValue =
        contract.availableQuantity > 0 ? contract.availableQuantity : 1.0;

    // Calculate booked percentage, ensure it's between 0 and 1
    final bookedPercentage =
        (contract.bookedQuantity / maxValue).clamp(0.0, 1.0);

    // Calculate shipped percentage, ensure it's between 0 and 1
    final shippedPercentage = contract.bookedQuantity > 0
        ? (contract.shippedQuantity / maxValue).clamp(0.0, 1.0)
        : 0.0;

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
          Container(
            width: 70,
            height: 5,
            color: colorFromString(contract.name),
          ),
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
                if (bookedPercentage > 0)
                  FractionallySizedBox(
                    widthFactor: bookedPercentage,
                    heightFactor: 1,
                    child: Container(
                      color: const Color.fromARGB(255, 194, 218, 135),
                    ),
                  ),
                if (shippedPercentage > 0)
                  FractionallySizedBox(
                    widthFactor: shippedPercentage,
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
                      color: const Color.fromARGB(255, 194, 218, 135),
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
                    color: const Color.fromARGB(255, 69, 131, 46),
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
