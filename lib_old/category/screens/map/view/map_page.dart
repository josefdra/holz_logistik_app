import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../../lib/l10n/l10n.dart';
import '../../location_list/location_list.dart';
import '../map.dart';
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
                mapController: context.read<MapBloc>().mapController,
                options: MapOptions(
                  initialCenter: const LatLng(47.9831, 11.9050),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    rotationThreshold: 30,
                  ),
                  onTap: (tapPosition, point) => context.read<MapBloc>().add(
                        MapMapTap(position: point),
                      ),
                  onMapEvent: (event) {
                    if (event is MapEventMoveStart) {
                      if (event.source == MapEventSource.dragStart ||
                          event.source ==
                              MapEventSource.multiFingerGestureStart) {
                        context
                            .read<MapBloc>()
                            .add(const MapDisableTrackingMode());
                      }
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.draexl_it.holz_logistik',
                  ),
                  MarkerLayer(
                    markers: [
                      if (state.userLocation != null)
                        Marker(
                          width: 25,
                          height: 25,
                          point: state.userLocation!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(51),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (state.addMarkerMode == true &&
                          state.newMarkerPosition != null)
                        Marker(
                          width: 50,
                          height: 50,
                          point: state.newMarkerPosition!,
                          child:
                              const Icon(Icons.location_on, color: Colors.red),
                        ),
                      ...state.locations.map(
                        (location) => Marker(
                          width: 50,
                          height: 50,
                          point: LatLng(location.latitude, location.longitude),
                          child: GestureDetector(
                            onTap: () => showDialog<LocationDetailsWidget>(
                              context: context,
                              builder: (context) => LocationDetailsWidget(
                                location: location,
                              ),
                            ),
                            child: Icon(
                              Icons.location_pin,
                              color: !location.started
                                  ? Colors.red
                                  : const Color.fromARGB(255, 0, 17, 255),
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: () => context.read<MapBloc>().add(
                            const MapResetMapRotation(),
                          ),
                      heroTag: 'mapPageNorthButton',
                      child: const Icon(Icons.navigation),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: () => context.read<MapBloc>().add(
                            const MapCenterToPosition(),
                          ),
                      heroTag: 'mapPageCenterPositionButton',
                      child: const Icon(Icons.my_location),
                    ),
                    const SizedBox(height: 10),
                    if (state.addMarkerMode)
                      FloatingActionButton(
                        onPressed: () => context
                            .read<MapBloc>()
                            .add(const MapToggleAddMarkerMode()),
                        heroTag: 'mapPageCancelAddMarkerModeButton',
                        child: const Icon(Icons.close),
                      ),
                    if (state.addMarkerMode) const SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: state.addMarkerMode
                          ? () {
                              if (state.newMarkerPosition != null) {
                                context
                                    .read<MapBloc>()
                                    .add(const MapToggleAddMarkerMode());
                                Navigator.of(context).push(
                                  EditLocationWidget.route(
                                    newMarkerPosition: state.newMarkerPosition,
                                  ),
                                );
                              }
                            }
                          : () => context
                              .read<MapBloc>()
                              .add(const MapToggleAddMarkerMode()),
                      heroTag: 'mapPageAddMarkerButton',
                      child: Icon(
                        state.addMarkerMode ? Icons.check : Icons.add_location,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(child: Text('© OpenStreetMap')),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: FloatingActionButton(
                  onPressed: () => context
                      .read<MapBloc>()
                      .add(const MapToggleMarkerInfoMode()),
                  heroTag: 'mapPageShownInfoButton',
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
