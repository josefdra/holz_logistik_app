import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/contracts/finished_contracts/finished_contracts.dart';
import 'package:holz_logistik/widgets/contract/contract_list_tile.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class FinishedContractsPage extends StatelessWidget {
  const FinishedContractsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => FinishedContractsBloc(
          contractRepository: context.read<ContractRepository>(),
        ),
        child: const FinishedContractsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinishedContractsBloc(
        contractRepository: context.read<ContractRepository>(),
      )..add(const FinishedContractsSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Abgeschlossene Verträge')),
        body: const FinishedContractsList(),
      ),
    );
  }
}

class FinishedContractsList extends StatelessWidget {
  const FinishedContractsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinishedContractsBloc, FinishedContractsState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildDatePickerRow(context, state),
            Expanded(
              child: _buildContent(context, state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDatePickerRow(
    BuildContext context,
    FinishedContractsState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () async {
            final pickedDateRange = await showDateRangePicker(
              context: context,
              initialDateRange: DateTimeRange(
                start: state.startDate,
                end: state.endDate,
              ),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );

            if (pickedDateRange != null) {
              final startDate = pickedDateRange.start;
              final endDate = pickedDateRange.end;

              if (context.mounted) {
                context.read<FinishedContractsBloc>().add(
                      FinishedContractsDateChanged(
                        startDate,
                        endDate.copyWith(hour: 23, minute: 59, second: 59),
                      ),
                    );
              }
            }
          },
          icon: const Icon(
            Icons.date_range,
          ),
        ),
        Center(
          child: Text('${state.startDate.day}.${state.startDate.month}.'
              '${state.startDate.year} - ${state.endDate.day}.'
              '${state.endDate.month}.${state.endDate.year}'),
        ),
        IconButton(
          onPressed: () => context
              .read<FinishedContractsBloc>()
              .add(const FinishedContractsAutomaticDate()),
          icon: const Icon(
            Icons.schedule,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, FinishedContractsState state) {
    if (state.contracts.isEmpty) {
      if (state.status == FinishedContractsStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state.status != FinishedContractsStatus.success) {
        return const SizedBox();
      } else {
        return Center(
          child: Text(
            'Nix',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }
    }

    return Scrollbar(
      controller: context.read<FinishedContractsBloc>().scrollController,
      child: ListView.builder(
        controller: context.read<FinishedContractsBloc>().scrollController,
        itemCount: state.contracts.length,
        itemBuilder: (_, index) {
          final contract = state.contracts.elementAt(index);
          return ContractListTile(
            contract: contract,
            onReactivate: () => context
                .read<FinishedContractsBloc>()
                .add(FinishedContractsReactivateContract(contract)),
          );
        },
      ),
    );
  }
}
