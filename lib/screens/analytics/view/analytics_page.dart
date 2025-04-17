import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/analytics/analytics.dart';
import 'package:holz_logistik/screens/contracts/contract_list/contract_list.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => AnalyticsPageBloc(),
        child: const AnalyticsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsPageBloc()
        ..add(const AnalyticsPageSubscriptionRequested()),
      child: Scaffold(
        body: Column(
          children: [
            const Expanded(
              child: Center(child: Text('Analyse')),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  shape: const BeveledRectangleBorder(),
                ),
                onPressed: () => Navigator.of(context).push(
                  ContractListPage.route(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Verträge'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
