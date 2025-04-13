import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/location_details/bloc/location_details_bloc.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/widgets.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class LocationDetailsWidget extends StatelessWidget {
  const LocationDetailsWidget({
    required this.location,
    super.key,
  });

  final Location location;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationDetailsBloc(
        locationsRepository: context.read<LocationRepository>(),
        contractRepository: context.read<ContractRepository>(),
        sawmillRepository: context.read<SawmillRepository>(),
        shipmentRepository: context.read<ShipmentRepository>(),
        initialLocation: location,
      )..add(const LocationDetailsSubscriptionRequested()),
      child: const LocationDetailsView(),
    );
  }
}

class LocationDetailsView extends StatelessWidget {
  const LocationDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<LocationDetailsBloc, LocationDetailsState>(
      builder: (context, state) {
        if (state.status == LocationDetailsStatus.loading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state.status != LocationDetailsStatus.success) {
          return const SizedBox();
        }

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.location.partieNr,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            Text(
                              state.contract.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                  Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FixedColumnWidth(120),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      3: FixedColumnWidth(60),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      const TableRow(
                        children: <Widget>[
                          SizedBox(height: 32),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Menge (fm)'),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Davon ÜS'),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Stück'),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          const SizedBox(
                            height: 32,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Anfangs:'),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('${state.location.initialQuantity}'),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${state.location.initialOversizeQuantity}',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Text('${state.location.initialPieceCount}'),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          const SizedBox(
                            height: 32,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Momentan:'),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('${state.location.initialQuantity}'),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${state.location.initialOversizeQuantity}',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Text('${state.location.initialPieceCount}'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Sägewerke:'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          state.sawmills
                              .map((sawmill) => sawmill.name)
                              .join(', '),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(
                        width: 120,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Sägewerke ÜS:'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          state.oversizeSawmills
                              .map((sawmill) => sawmill.name)
                              .join(', '),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(state.location.additionalInfo),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Column(
                            children: [
                              IconButton.filled(
                                onPressed: () {},
                                icon: const Icon(Icons.local_shipping),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  minimumSize: const Size(48, 48),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('Abfuhr'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Column(
                            children: [
                              IconButton.filled(
                                onPressed: () =>
                                    startNavigation(state.location),
                                icon: const Icon(Icons.assistant_navigation),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  minimumSize: const Size(48, 48),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text('Navigation'),
                            ],
                          ),
                        ),
                      ),
                      if (context
                          .read<AuthenticationRepository>()
                          .userHasElevatedPrivileges)
                        SizedBox(
                          width: 100,
                          child: Center(
                            child: Column(
                              children: [
                                IconButton.filled(
                                  onPressed: () => Navigator.of(context).push(
                                    EditLocationWidget.route(
                                        initialLocation: state.location),
                                  ),
                                  icon: const Icon(Icons.edit),
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    minimumSize: const Size(48, 48),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text('Bearbeiten'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
