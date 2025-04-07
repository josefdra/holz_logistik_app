import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
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
            ],
          );
        },
      ),
    );
  }
}
