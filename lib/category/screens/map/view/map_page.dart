import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik/category/screens/map/map.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => MapBloc(
          locationRepository: context.read<LocationRepository>(),
        ),
        child: const MapPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(
        locationRepository: context.read<LocationRepository>(),
      )..add(const MapSubscriptionRequested()),
      child: const Scaffold(
        body: Map(),
      ),
    );
  }
}

class Map extends StatelessWidget {
  const Map({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<MapBloc, MapState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == MapStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.mapErrorSnackbarText),
                  ),
                );
            }
          },
        ),
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state.status == MapStatus.loading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (state.status != MapStatus.success) {
            return const SizedBox();
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: MapController(),
                options: const MapOptions(
                  initialCenter: LatLng(47.9831, 11.9050),
                  initialZoom: 10,
                  interactionOptions: InteractionOptions(
                    rotationThreshold: 30,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.draexl_it.holz_logistik',
                  ),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // North orientation button
                    FloatingActionButton(
                      onPressed: () => context.read<MapBloc>().add(
                            const MapResetMapRotation(),
                          ),
                      heroTag: 'mapPageNorthButton',
                      child: const Icon(Icons.navigation),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      onPressed: () => context.read<MapBloc>().add(
                            const MapCenterToPosition(),
                          ),
                      heroTag: 'mapPageCenterPositionButton',
                      child: const Icon(Icons.my_location),
                    ),
                    const SizedBox(height: 8),
                    if (state.addMarkerMode)
                      FloatingActionButton(
                        onPressed: () => context
                            .read<MapBloc>()
                            .add(const MapToggleAddMarkerMode()),
                        heroTag: 'mapPageCancelAddMarkerModeButton',
                        child: const Icon(Icons.close),
                      ),
                    if (state.addMarkerMode) const SizedBox(height: 8),
                    FloatingActionButton(
                      onPressed: state.addMarkerMode
                          ? () => Navigator.of(context).push(
                                EditLocationWidget.route(
                                  newMarker: state.newMarker,
                                ),
                              )
                          : () => context
                              .read<MapBloc>()
                              .add(const MapToggleAddMarkerMode()),
                      heroTag: 'addButton',
                      child: Icon(
                        state.addMarkerMode ? Icons.check : Icons.add_location,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: FloatingActionButton(
                  onPressed: () => context
                      .read<MapBloc>()
                      .add(const MapToggleMarkerInfoMode()),
                  heroTag: 'infoButton',
                  child: Icon(
                    state.showInfoMode ? Icons.info_outline : Icons.info,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
