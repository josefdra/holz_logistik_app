import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/locations/finished_locations/finished_locations.dart';
import 'package:holz_logistik/widgets/locations/location_list_tile.dart';
import 'package:holz_logistik_backend/repository/location_repository.dart';

class FinishedLocationsPage extends StatelessWidget {
  const FinishedLocationsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => FinishedLocationsBloc(
          locationRepository: context.read<LocationRepository>(),
        ),
        child: const FinishedLocationsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinishedLocationsBloc(
        locationRepository: context.read<LocationRepository>(),
      )..add(const FinishedLocationsSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Abgeschlossene Standorte')),
        body: const FinishedLocationsList(),
      ),
    );
  }
}

class FinishedLocationsList extends StatelessWidget {
  const FinishedLocationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinishedLocationsBloc, FinishedLocationsState>(
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
    FinishedLocationsState state,
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
                context.read<FinishedLocationsBloc>().add(
                      FinishedLocationsDateChanged(
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
              .read<FinishedLocationsBloc>()
              .add(const FinishedLocationsAutomaticDate()),
          icon: const Icon(
            Icons.schedule,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, FinishedLocationsState state) {
    if (state.locations.isEmpty) {
      if (state.status == FinishedLocationsStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state.status != FinishedLocationsStatus.success) {
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
      controller: context.read<FinishedLocationsBloc>().scrollController,
      child: ListView.builder(
        controller: context.read<FinishedLocationsBloc>().scrollController,
        itemCount: state.locations.length,
        itemBuilder: (_, index) {
          final location = state.locations.elementAt(index);
          return LocationListTile(
            location: location,
            onTap: () {
              print('Show location details widget');
            },
          );
        },
      ),
    );
  }
}
