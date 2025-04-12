import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/location_details_widget/bloc/location_details_bloc.dart';
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
            child: Container(
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
                  Text(
                    state.location.partieNr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
