import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik_backend/repository/location_repository.dart';
import 'package:holz_logistik_backend/repository/src_shipment/shipment_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'location_list_event.dart';
part 'location_list_state.dart';

class LocationListBloc extends Bloc<LocationListEvent, LocationListState> {
  LocationListBloc({
    required LocationRepository locationRepository,
    required ShipmentRepository shipmentRepository,
  })  : _locationRepository = locationRepository,
        _shipmentRepository = shipmentRepository,
        super(LocationListState()) {
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
    emit(state.copyWith(lastDeletedLocation: event.location));
    await _locationRepository.deleteLocation(
      id: event.location.id,
      done: event.location.done,
    );

    await _shipmentRepository.deleteShipmentsByLocationId(event.location.id);
  }

  void _onSearchQueryChanged(
    LocationListSearchQueryChanged event,
    Emitter<LocationListState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: LocationListSearchQuery(searchQuery: event.searchQuery),
      ),
    );
  }

  @override
  Future<void> close() {
    state.scrollController.dispose();
    return super.close();
  }
}
