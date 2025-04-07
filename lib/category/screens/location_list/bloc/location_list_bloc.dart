import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik_backend/repository/location_repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'location_list_event.dart';
part 'location_list_state.dart';

class LocationListBloc extends Bloc<LocationListEvent, LocationListState> {
  LocationListBloc({
    required LocationRepository locationRepository,
  })  : _locationRepository = locationRepository,
        super(const LocationListState()) {
    on<LocationListSubscriptionRequested>(_onSubscriptionRequested);
    on<LocationListLocationDeleted>(_onLocationDeleted);
    on<LocationListUndoDeletionRequested>(_onUndoDeletionRequested);
    on<LocationListSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(
        const Duration(milliseconds: 300),
      ),
    );
  }

  final LocationRepository _locationRepository;

  Future<void> _onSubscriptionRequested(
    LocationListSubscriptionRequested event,
    Emitter<LocationListState> emit,
  ) async {
    emit(state.copyWith(status: () => LocationListStatus.loading));

    await emit.forEach<List<Location>>(
      _locationRepository.locations,
      onData: (locations) => state.copyWith(
        status: () => LocationListStatus.success,
        locations: () => locations,
      ),
      onError: (_, __) => state.copyWith(
        status: () => LocationListStatus.failure,
      ),
    );
  }

  Future<void> _onLocationDeleted(
    LocationListLocationDeleted event,
    Emitter<LocationListState> emit,
  ) async {
    emit(state.copyWith(lastDeletedLocation: () => event.location));
    await _locationRepository.deleteLocation(event.location.id);
  }

  Future<void> _onUndoDeletionRequested(
    LocationListUndoDeletionRequested event,
    Emitter<LocationListState> emit,
  ) async {
    assert(
      state.lastDeletedLocation != null,
      'Last deleted location can not be null.',
    );

    final location = state.lastDeletedLocation!;
    emit(state.copyWith(lastDeletedLocation: () => null));
    await _locationRepository.saveLocation(location);
  }

  void _onSearchQueryChanged(
    LocationListSearchQueryChanged event,
    Emitter<LocationListState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: () =>
            LocationListSearchQuery(searchQuery: event.searchQuery),
      ),
    );
  }
}
