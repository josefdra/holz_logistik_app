import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/contracts/finished_contracts/finished_contracts.dart';
import 'package:holz_logistik/widgets/contract/contract_list_tile.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class FinishedContractPage extends StatelessWidget {
  const FinishedContractPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => FinishedContractBloc(
          contractRepository: context.read<ContractRepository>(),
        ),
        child: const FinishedContractPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinishedContractBloc(
        contractRepository: context.read<ContractRepository>(),
      )..add(const FinishedContractSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Abgeschlossene Verträge')),
        body: const FinishedContractList(),
      ),
    );
  }
}

class FinishedContractList extends StatelessWidget {
  const FinishedContractList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinishedContractBloc, FinishedContractState>(
      builder: (context, state) {
        if (state.contracts.isEmpty) {
          if (state.status == FinishedContractStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status != FinishedContractStatus.success) {
            return const SizedBox();
          } else {
            return Center(
              child: Text(
                'Keine abgeschlossenen Verträge',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
        }

        return Scrollbar(
          controller: context.read<FinishedContractBloc>().scrollController,
          child: ListView.builder(
            controller: context.read<FinishedContractBloc>().scrollController,
            itemCount: state.contracts.length,
            itemBuilder: (_, index) {
              final contract = state.contracts.elementAt(index);
              return ContractListTile(
                contract: contract,
                onTap: () {
                  print('Show contract details widget');
                },
              );
            },
          ),
        );
      },
    );
  }
}
