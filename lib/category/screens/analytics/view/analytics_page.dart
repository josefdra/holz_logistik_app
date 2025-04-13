import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/analytics/analytics.dart';
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
        body: const ContractList(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'analyticsPageFloatingActionButton',
          shape: const CircleBorder(),
          onPressed: () => Navigator.of(context).push(
            EditContractWidget.route(),
          ),
          child: const Icon(Icons.add),
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
        BlocListener<AnalyticsBloc, AnalyticsState>(
          listenWhen: (previous, current) =>
              previous.lastDeletedContract != current.lastDeletedContract &&
              current.lastDeletedContract != null,
          listener: (context, state) {
            final deletedContract = state.lastDeletedContract!;
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.contractListContractDeletedSnackbarText(
                      deletedContract.title,
                    ),
                  ),
                  action: SnackBarAction(
                    label: l10n.contractListUndoDeletionButtonText,
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      context
                          .read<AnalyticsBloc>()
                          .add(const AnalyticsUndoDeletionRequested());
                    },
                  ),
                ),
              );
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
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: state.contracts.length,
              itemBuilder: (_, index) {
                final contract = state.contracts.elementAt(index);
                return ContractListTile(
                  contract: contract,
                  onDismissed: (_) {
                    context.read<AnalyticsBloc>().add(
                          AnalyticsContractDeleted(contract),
                        );
                  },
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
