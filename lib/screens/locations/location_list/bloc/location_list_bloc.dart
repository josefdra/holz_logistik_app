import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/general/general.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'location_list_event.dart';
part 'location_list_state.dart';

class LocationListBloc extends Bloc<LocationListEvent, LocationListState> {
  LocationListBloc({
    required LocationRepository locationRepository,
    required ShipmentRepository shipmentRepository,
    required PhotoRepository photoRepository,
  })  : _locationRepository = locationRepository,
        _shipmentRepository = shipmentRepository,
        _photoRepository = photoRepository,
        super(const LocationListState()) {
    on<LocationListSubscriptionRequested>(_onSubscriptionRequested);
    on<LocationListLocationDeleted>(_onLocationDeleted);
    on<LocationListSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(
        const Duration(milliseconds: 300),
      ),
    );
  }

  final LocationRepository _locationRepository;
  final ShipmentRepository _shipmentRepository;
  final PhotoRepository _photoRepository;
  final scrollController = ScrollController();

  Future<void> _onSubscriptionRequested(
    LocationListSubscriptionRequested event,
    Emitter<LocationListState> emit,
  ) async {
    emit(state.copyWith(status: LocationListStatus.loading));

    await emit.forEach<List<Location>>(
      _locationRepository.activeLocations,
      onData: (locations) => state.copyWith(
        status: LocationListStatus.success,
        locations: locations,
      ),
      onError: (_, __) => state.copyWith(
        status: LocationListStatus.failure,
      ),
    );
  }

  Future<void> _onLocationDeleted(
    LocationListLocationDeleted event,
    Emitter<LocationListState> emit,
  ) async {
    await _locationRepository.deleteLocation(
      id: event.location.id,
      done: event.location.done,
    );

    await _shipmentRepository.deleteShipmentsByLocationId(event.location.id);
    await _photoRepository.deletePhotosByLocationId(
      locationId: event.location.id,
    );
  }

  void _onSearchQueryChanged(
    LocationListSearchQueryChanged event,
    Emitter<LocationListState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: SearchQuery(searchQuery: event.searchQuery),
      ),
    );
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
