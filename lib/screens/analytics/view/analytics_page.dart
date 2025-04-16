import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/l10n.dart';
import '../analytics.dart';
import '../../../../lib_old/category/screens/analytics/widgets/contracts/view/contracts_page.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static Route<void> route({Contract? initialContract}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => AnalyticsBloc(
          contractRepository: context.read<ContractRepository>(),
        ),
        child: const AnalyticsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsBloc(
        contractRepository: context.read<ContractRepository>(),
      )..add(const AnalyticsSubscriptionRequested()),
      child: Scaffold(
        body: Column(
          children: [
            const Expanded(
              child: ContractList(),
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
                  ContractPage.route(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Zusätzliches'),
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

class ContractList extends StatelessWidget {
  const ContractList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<AnalyticsBloc, AnalyticsState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == AnalyticsStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.contractListErrorSnackbarText),
                  ),
                );
            }
          },
        ),
      ],
      child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state.contracts.isEmpty) {
            if (state.status == AnalyticsStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state.status != AnalyticsStatus.success) {
              return const SizedBox();
            } else {
              return Center(
                child: Text(
                  l10n.contractListEmptyText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
          }

          return CupertinoScrollbar(
            controller: state.scrollController,
            child: ListView.builder(
              controller: state.scrollController,
              itemCount: state.contracts.length,
              itemBuilder: (_, index) {
                final contract = state.contracts.elementAt(index);
                return ContractListTile(
                  contract: contract,
                  onTap: () {},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
