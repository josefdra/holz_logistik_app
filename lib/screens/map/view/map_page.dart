import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/screens/locations/edit_location/edit_location.dart';
import 'package:holz_logistik/screens/map/map.dart';
import 'package:holz_logistik/widgets/locations/location_details/location_details.dart';
import 'package:holz_logistik/widgets/map/map_marker.dart';
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
          authenticationRepository: context.read<AuthenticationRepository>(),
          sawmillRepository: context.read<SawmillRepository>(),
          contractRepository: context.read<ContractRepository>(),
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
        authenticationRepository: context.read<AuthenticationRepository>(),
        sawmillRepository: context.read<SawmillRepository>(),
        contractRepository: context.read<ContractRepository>(),
      )..add(const MapSubscriptionRequested()),
      child: const Scaffold(
        body: MapView(),
      ),
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == MapStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Fehler beim Laden der Karte'),
              ),
            );
        }
      },
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state.status == MapStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status != MapStatus.success) {
            return const SizedBox();
          }

          return Stack(
            children: [
              _buildMap(context, state),
              _buildRightActionButtons(context, state),
              _buildCopyrightNotice(),
              _buildInfoButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapState state) {
    return FlutterMap(
      mapController: context.read<MapBloc>().mapController,
      options: MapOptions(
        onMapReady: () => context.read<MapBloc>().add(const MapMapReady()),
        initialCenter: const LatLng(47.9831, 11.9050),
        initialZoom: 12,
        interactionOptions: const InteractionOptions(
          rotationThreshold: 30,
        ),
        onTap: (tapPosition, point) => context.read<MapBloc>().add(
              MapMapTap(position: point),
            ),
        onMapEvent: (event) {
          if (event is MapEventMoveStart) {
            if (event.source == MapEventSource.dragStart ||
                event.source == MapEventSource.multiFingerGestureStart) {
              context.read<MapBloc>().add(const MapDisableTrackingMode());
            }
          }
        },
      ),
      children: [
        _buildTileLayer(),
        _buildMarkerLayer(context, state),
      ],
    );
  }

  Widget _buildTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.draexl_it.holz_logistik',
    );
  }

  Widget _buildMarkerLayer(BuildContext context, MapState state) {
    return MarkerLayer(
      alignment: const Alignment(0, -0.9),
      markers: [
        if (state.userLocation != null)
          _buildUserLocationMarker(state.userLocation!),
        if (state.addMarkerMode == true && state.newMarkerPosition != null)
          _buildNewPositionMarker(state.newMarkerPosition!),
        ...state.locations.expand(
          (location) => _buildLocationMarker(
            context,
            location,
            state.contractNames[location.contractId] ?? '',
          ),
        ),
      ],
    );
  }

  Marker _buildUserLocationMarker(LatLng position) {
    return Marker(
      alignment: Alignment.center,
      width: 25,
      height: 25,
      point: position,
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
    );
  }

  Marker _buildNewPositionMarker(LatLng position) {
    return Marker(
      alignment: const Alignment(0, -0.5),
      width: 50,
      height: 50,
      point: position,
      child: const Icon(Icons.location_on, color: Colors.red),
    );
  }

  List<Marker> _buildLocationMarker(
    BuildContext context,
    Location location,
    String contractName,
  ) {
    void onTap() {
      showDialog<void>(
        context: context,
        builder: (context) => LocationDetailsWidget(
          location: location.copyWith(),
        ),
      );
    }

    final sawmills = context.read<MapBloc>().state.sawmills;

    final mapMarker = MapMarker(
      location: location,
      sawmills: sawmills,
      contractName: contractName,
      onTap: onTap,
      infoMode: context.read<MapBloc>().state.showInfoMode,
    );

    return mapMarker.build();
  }

  Widget _buildRightActionButtons(BuildContext context, MapState state) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            onPressed: () => context.read<MapBloc>().add(
                  const MapResetMapRotation(),
                ),
            heroTag: 'mapPageNorthButton',
            icon: Icons.navigation,
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            onPressed: () => context.read<MapBloc>().add(
                  const MapCenterToPosition(),
                ),
            heroTag: 'mapPageCenterPositionButton',
            icon: Icons.my_location,
          ),
          if (state.user.role.isPrivileged) const SizedBox(height: 10),
          if (state.addMarkerMode)
            _buildActionButton(
              onPressed: () =>
                  context.read<MapBloc>().add(const MapToggleAddMarkerMode()),
              heroTag: 'mapPageCancelAddMarkerModeButton',
              icon: Icons.close,
            ),
          if (state.addMarkerMode) const SizedBox(height: 10),
          if (state.user.role.isPrivileged)
            _buildActionButton(
              onPressed: state.addMarkerMode
                  ? () {
                      if (state.newMarkerPosition != null) {
                        context
                            .read<MapBloc>()
                            .add(const MapToggleAddMarkerMode());
                        Navigator.of(context).push(
                          EditLocationPage.route(
                            newMarkerPosition: state.newMarkerPosition,
                          ),
                        );
                      }
                    }
                  : () => context
                      .read<MapBloc>()
                      .add(const MapToggleAddMarkerMode()),
              heroTag: 'mapPageAddMarkerButton',
              icon: state.addMarkerMode ? Icons.check : Icons.add_location,
            ),
        ],
      ),
    );
  }

  Widget _buildCopyrightNotice() {
    return const Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(child: Text('© OpenStreetMap')),
    );
  }

  Widget _buildInfoButton(BuildContext context, MapState state) {
    return Positioned(
      bottom: 10,
      left: 10,
      child: _buildActionButton(
        onPressed: () =>
            context.read<MapBloc>().add(const MapToggleMarkerInfoMode()),
        heroTag: 'mapPageShownInfoButton',
        icon: state.showInfoMode ? Icons.info_outline : Icons.info,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String heroTag,
    required IconData icon,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag,
      child: Icon(icon),
    );
  }
}
