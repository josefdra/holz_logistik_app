import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/analytics/analytics.dart';
import 'package:holz_logistik/screens/contracts/contract_list/contract_list.dart';
import 'package:holz_logistik/widgets/analytics/analytics.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => AnalyticsPageBloc(
          shipmentRepository: context.read<ShipmentRepository>(),
          sawmillRepository: context.read<SawmillRepository>(),
          locationRepository: context.read<LocationRepository>(),
        ),
        child: const AnalyticsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnalyticsPageBloc(
        shipmentRepository: context.read<ShipmentRepository>(),
        sawmillRepository: context.read<SawmillRepository>(),
        locationRepository: context.read<LocationRepository>(),
      )..add(const AnalyticsPageSubscriptionRequested()),
      child: Scaffold(
        body: const AnalyticsView(),
        bottomSheet: SizedBox(
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
      ),
    );
  }
}

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnalyticsPageBloc, AnalyticsPageState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AnalyticsPageStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Error'),
              ),
            );
        }
      },
      child: BlocBuilder<AnalyticsPageBloc, AnalyticsPageState>(
        builder: (context, state) {
          if (state.analyticsData.isEmpty) {
            if (state.status == AnalyticsPageStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status != AnalyticsPageStatus.success) {
              return const SizedBox();
            } else {
              return Center(
                child: Text(
                  'Keine Analyse vorhanden',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
          }

          return Scrollbar(
            controller: context.read<AnalyticsPageBloc>().scrollController,
            child: ListView(
              controller: context.read<AnalyticsPageBloc>().scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Insgesamt verfügbar:'),
                      Text('Menge: ${state.totalCurrentQuantity}fm'),
                      Text('Davon ÜS: ${state.totalCurrentOversizeQuantity}fm'),
                      Text('Stückzahl: ${state.totalCurrentPieceCount}fm'),
                    ],
                  ),
                ),
                _buildDatePickerRow(context, state),
                ...state.analyticsData.values.map((dataElement) {
                  return AnalyticsListTile(
                    data: dataElement,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatePickerRow(
    BuildContext context,
    AnalyticsPageState state,
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

            if (pickedDateRange != null && context.mounted) {
              context.read<AnalyticsPageBloc>().add(
                    AnalyticsPageDateChanged(
                      pickedDateRange.start,
                      pickedDateRange.end
                          .copyWith(hour: 23, minute: 59, second: 59),
                    ),
                  );
            }
          },
          icon: const Icon(Icons.date_range),
        ),
        Center(
          child: Text('${state.startDate.day}.${state.startDate.month}.'
              '${state.startDate.year} - ${state.endDate.day}.'
              '${state.endDate.month}.${state.endDate.year}'),
        ),
        IconButton(
          onPressed: () => context
              .read<AnalyticsPageBloc>()
              .add(const AnalyticsPageAutomaticDate()),
          icon: const Icon(Icons.schedule),
        ),
      ],
    );
  }
}
