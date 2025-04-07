import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/category/screens/map/models/markers_from_locations.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required LocationRepository locationRepository,
  })  : _locationRepository = locationRepository,
        super(const MapState()) {
    on<MapSubscriptionRequested>(_onSubscriptionRequested);
    on<MapResetMapRotation>(_onResetMapRotation);
    on<MapCenterToPosition>(_onCenterToPosition);
    on<MapToggleAddMarkerMode>(_onToggleAddMarkerMode);
    on<MapToggleMarkerInfoMode>(_onToggleMarkerInfoMode);
  }

  final LocationRepository _locationRepository;

  Future<void> _onSubscriptionRequested(
    MapSubscriptionRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(status: MapStatus.loading));

    await emit.forEach<List<Location>>(
      _locationRepository.locations,
      onData: (locations) => state.copyWith(
        status: MapStatus.success,
        markers: markersFromLocations(locations),
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
  }

  Future<void> _onCenterToPosition(
    MapCenterToPosition event,
    Emitter<MapState> emit,
  ) async {
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
}
