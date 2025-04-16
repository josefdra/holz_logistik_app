import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/analytics/widgets/contracts/contracts.dart';
import 'package:holz_logistik/category/screens/analytics/widgets/contracts/widgets/finished_contracts/view/finished_contracts_page.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class ContractPage extends StatelessWidget {
  const ContractPage({super.key});

  static Route<void> route({Contract? initialContract}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => ContractBloc(
          contractRepository: context.read<ContractRepository>(),
        ),
        child: const ContractPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContractBloc(
        contractRepository: context.read<ContractRepository>(),
      )..add(const ContractSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Verträge')),
        body: const ContractList(),
        bottomSheet: SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 30),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.secondary,
              shape: const BeveledRectangleBorder(),
            ),
            onPressed: () {
              Navigator.of(context).push(FinishedContractPage.route());
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Abgeschlossene Verträge'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: FloatingActionButton(
            heroTag: 'analyticsPageFloatingActionButton',
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            onPressed: () => Navigator.of(context).push(
              EditContractWidget.route(),
            ),
            child: const Icon(Icons.add),
          ),
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
        BlocListener<ContractBloc, ContractState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == ContractStatus.failure) {
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
      child: BlocBuilder<ContractBloc, ContractState>(
        builder: (context, state) {
          if (state.contracts.isEmpty) {
            if (state.status == ContractStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state.status != ContractStatus.success) {
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
                  onTap: () {
                    Navigator.of(context).push(
                      EditContractWidget.route(initialContract: contract),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
