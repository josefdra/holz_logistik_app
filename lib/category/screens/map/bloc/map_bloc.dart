import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/category/screens/map/map.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required LocationRepository locationRepository,
  })  : _locationRepository = locationRepository,
        _locationService = LocationService(),
        super(const MapState()) {
    on<MapSubscriptionRequested>(_onSubscriptionRequested);
    on<MapResetMapRotation>(_onResetMapRotation);
    on<MapCenterToPosition>(_onCenterToPosition);
    on<MapToggleAddMarkerMode>(_onToggleAddMarkerMode);
    on<MapToggleMarkerInfoMode>(_onToggleMarkerInfoMode);
    on<MapLocationUpdated>(_onLocationUpdated);
    on<MapDisableTrackingMode>(_onDisableTrackingMode);
    on<MapMapTap>(_onMapTap);

    _initLocationTracking();
  }

  final LocationRepository _locationRepository;
  final MapController mapController = MapController();
  final LocationService _locationService;

  Future<void> _initLocationTracking() async {
    await _locationService.initLocationService((latitude, longitude) {
      add(
        MapLocationUpdated(
          latitude: latitude,
          longitude: longitude,
        ),
      );
    });
  }

  Future<void> _onSubscriptionRequested(
    MapSubscriptionRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(status: MapStatus.loading));

    await emit.forEach<List<Location>>(
      _locationRepository.activeLocations,
      onData: (locations) => state.copyWith(
        status: MapStatus.success,
        locations: locations,
      ),
      onError: (_, __) => state.copyWith(
        status: MapStatus.failure,
      ),
    );
  }

  Future<void> _onResetMapRotation(
    MapResetMapRotation event,
    Emitter<MapState> emit,
  ) async {
    mapController.rotate(0);
  }

  Future<void> _onCenterToPosition(
    MapCenterToPosition event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(trackingMode: true));
    mapController.rotate(0);

    if (state.trackingMode && state.userLocation != null) {
      mapController.move(state.userLocation!, 15);
    }
  }

  Future<void> _onToggleAddMarkerMode(
    MapToggleAddMarkerMode event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(addMarkerMode: !state.addMarkerMode));
  }

  Future<void> _onToggleMarkerInfoMode(
    MapToggleMarkerInfoMode event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(showInfoMode: !state.showInfoMode));
  }

  Future<void> _onLocationUpdated(
    MapLocationUpdated event,
    Emitter<MapState> emit,
  ) async {
    final newLocation = LatLng(event.latitude, event.longitude);

    emit(
      state.copyWith(
        userLocation: newLocation,
      ),
    );

    if (state.trackingMode) {
      mapController.move(newLocation, mapController.camera.zoom);
    }
  }

  Future<void> _onDisableTrackingMode(
    MapDisableTrackingMode event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(trackingMode: false));
  }

  Future<void> _onMapTap(
    MapMapTap event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(trackingMode: false, newMarkerPosition: event.position),
    );
  }

  @override
  Future<void> close() {
    _locationService.dispose();
    return super.close();
  }
}
