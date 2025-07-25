import 'package:flutter/material.dart';
import 'package:holz_logistik/models/analytics/analytics.dart';
import 'package:holz_logistik_backend/general/models/round.dart';

class AnalyticsSawmillListTile extends StatelessWidget {
  const AnalyticsSawmillListTile({
    required this.data,
    super.key,
  });

  final AnalyticsDataElement data;

  @override
  Widget build(BuildContext context) {
    final oversizePercentage = data.oversizeQuantity / data.quantity;

    return ListTile(
      title: Text(data.sawmillName),
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
                  color: const Color.fromARGB(255, 170, 224, 239),
                ),
                FractionallySizedBox(
                  widthFactor: oversizePercentage > 1 ? 1 : oversizePercentage,
                  heightFactor: 1,
                  child: Container(
                    color: const Color.fromARGB(255, 100, 169, 212),
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
                      text: 'Menge: ${customRound(data.quantity)} fm',
                      color: const Color.fromARGB(255, 170, 224, 239),
                    ),
                    _buildLegendItem(
                      text: 'Stückzahl: ${data.pieceCount} Stk',
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    text: 'Davon ÜS: ${customRound(data.oversizeQuantity)} fm',
                    color: const Color.fromARGB(255, 100, 169, 212),
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
