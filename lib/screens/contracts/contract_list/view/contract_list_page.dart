import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:holz_logistik/screens/contracts/contract_list/contract_list.dart';
import 'package:holz_logistik/screens/contracts/finished_contracts/finished_contracts.dart';
import 'package:holz_logistik/widgets/contract/contract_list_tile.dart';
import 'package:holz_logistik/widgets/contract/edit_contract/edit_contract.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class ContractListPage extends StatelessWidget {
  const ContractListPage({super.key});

  static Route<void> route({Contract? initialContract}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => ContractListBloc(
          contractRepository: context.read<ContractRepository>(),
        ),
        child: const ContractListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContractListBloc(
        contractRepository: context.read<ContractRepository>(),
      )..add(const ContractListSubscriptionRequested()),
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
              Navigator.of(context).push(FinishedContractsPage.route());
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
            onPressed: () => showDialog<EditContractWidget>(
              context: context,
              builder: (context) => const EditContractWidget(),
            ),
            child: const Icon(Icons.add_circle_outline),
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

    return BlocListener<ContractListBloc, ContractListState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ContractListStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.contractListErrorSnackbarText),
              ),
            );
        }
      },
      child: BlocBuilder<ContractListBloc, ContractListState>(
        builder: (context, state) {
          if (state.contracts.isEmpty) {
            if (state.status == ContractListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status != ContractListStatus.success) {
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

          return Scrollbar(
            controller: context.read<ContractListBloc>().scrollController,
            child: ListView.builder(
              controller: context.read<ContractListBloc>().scrollController,
              itemCount: state.contracts.length,
              itemBuilder: (_, index) {
                final contract = state.contracts.elementAt(index);
                return ContractListTile(
                  contract: contract,
                  onTap: () => showDialog<EditContractWidget>(
                    context: context,
                    builder: (context) =>
                        EditContractWidget(contract: contract),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
