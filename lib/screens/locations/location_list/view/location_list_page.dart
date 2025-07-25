import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/locations/finished_locations/finished_locations.dart';
import 'package:holz_logistik/screens/locations/location_list/location_list.dart';
import 'package:holz_logistik/widgets/locations/location_widgets.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class LocationListPage extends StatelessWidget {
  const LocationListPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => LocationListBloc(
          locationRepository: context.read<LocationRepository>(),
          shipmentRepository: context.read<ShipmentRepository>(),
          photoRepository: context.read<PhotoRepository>(),
          contractRepository: context.read<ContractRepository>(),
        ),
        child: const LocationListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationListBloc(
        locationRepository: context.read<LocationRepository>(),
        shipmentRepository: context.read<ShipmentRepository>(),
        photoRepository: context.read<PhotoRepository>(),
        contractRepository: context.read<ContractRepository>(),
      )..add(const LocationListSubscriptionRequested()),
      child: Scaffold(
        body: Column(
          children: [
            const Expanded(
              child: LocationList(),
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
                onPressed: () {
                  Navigator.of(context).push(FinishedLocationsPage.route());
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Abgeschlossene Standorte'),
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

class LocationList extends StatelessWidget {
  const LocationList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationListBloc, LocationListState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) async {
        if (state.status == LocationListStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content:
                    Text('Beim Laden der Standorte ist ein Fehler aufgetreten'),
              ),
            );
        }
      },
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Standort suchen',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              context.read<LocationListBloc>().add(
                    LocationListSearchQueryChanged(value),
                  );
            },
          ),
          Expanded(
            child: BlocBuilder<LocationListBloc, LocationListState>(
              builder: (context, state) {
                if (state.locations.isEmpty) {
                  if (state.status == LocationListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!state.status.isShowDetailsOrSuccess) {
                    return const SizedBox();
                  } else {
                    return Center(
                      child: Text(
                        'Keine Standorte verfügbar',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }
                }

                return Scrollbar(
                  controller: context.read<LocationListBloc>().scrollController,
                  child: ListView.builder(
                    controller:
                        context.read<LocationListBloc>().scrollController,
                    itemCount: state.searchQueryedLocations.length,
                    itemBuilder: (_, index) {
                      final location =
                          state.searchQueryedLocations.elementAt(index);
                      return LocationListTile(
                        location: location,
                        contractName:
                            state.contractNames[location.contractId] ?? '',
                        photo: state.photos[location.id],
                        onTap: () => showDialog<LocationDetailsWidget>(
                          context: context,
                          builder: (context) => LocationDetailsWidget(
                            location: location,
                          ),
                        ),
                        onDelete: !location.started
                            ? () => context
                                .read<LocationListBloc>()
                                .add(LocationListLocationDeleted(location))
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
