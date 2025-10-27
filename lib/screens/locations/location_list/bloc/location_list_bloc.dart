import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/general/general.dart';
import 'package:holz_logistik/models/locations/location_list_sort.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:stream_transform/stream_transform.dart';

part 'location_list_event.dart';
part 'location_list_state.dart';

class LocationListBloc extends Bloc<LocationListEvent, LocationListState> {
  LocationListBloc({
    required LocationRepository locationRepository,
    required ShipmentRepository shipmentRepository,
    required PhotoRepository photoRepository,
    required ContractRepository contractRepository,
  })  : _locationRepository = locationRepository,
        _shipmentRepository = shipmentRepository,
        _photoRepository = photoRepository,
        _contractRepository = contractRepository,
        super(const LocationListState()) {
    on<LocationListSubscriptionRequested>(_onSubscriptionRequested);
    on<LocationListLocationsUpdate>(_onLocationsUpdate);
    on<LocationListLocationDeleted>(_onLocationDeleted);
    on<LocationListContractUpdate>(_onContractUpdate);
    on<LocationListSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(
        const Duration(milliseconds: 300),
      ),
    );
    on<LocationListSortChanged>(_onSortChanged);
  }

  final LocationRepository _locationRepository;
  final ShipmentRepository _shipmentRepository;
  final PhotoRepository _photoRepository;
  final ContractRepository _contractRepository;
  final scrollController = ScrollController();

  late final StreamSubscription<List<Location>>? _locationSubscription;
  late final StreamSubscription<Contract>? _contractSubscription;

  Future<void> _onSubscriptionRequested(
    LocationListSubscriptionRequested event,
    Emitter<LocationListState> emit,
  ) async {
    emit(state.copyWith(status: LocationListStatus.loading));

    _locationSubscription = _locationRepository.activeLocations.listen(
      (locations) => add(LocationListLocationsUpdate(locations: locations)),
    );

    _contractSubscription =
        _contractRepository.contractUpdates.listen((contract) {
      add(const LocationListContractUpdate());
    });
  }

  Future<void> _onLocationsUpdate(
    LocationListLocationsUpdate event,
    Emitter<LocationListState> emit,
  ) async {
    final contractNames = <String, String>{};
    final locationHasShipments = <String, bool>{};

    for (final location in event.locations) {
      final contract =
          await _contractRepository.getContractById(location.contractId);
      contractNames[location.contractId] = contract.name;
      locationHasShipments[location.id] =
          (await _shipmentRepository.getShipmentsByLocation(location.id))
              .isNotEmpty;
    }

    final sortedLocations = _sortLocations(event.locations, state.sort);

    emit(
      state.copyWith(
        status: LocationListStatus.success,
        locations: sortedLocations,
        contractNames: contractNames,
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

    final contract =
        await _contractRepository.getContractById(event.location.contractId);
    final updatedContract = contract.copyWith(
      bookedQuantity: contract.bookedQuantity - event.location.currentQuantity,
    );

    await _contractRepository.saveContract(updatedContract);
  }

  Future<void> _onContractUpdate(
    LocationListContractUpdate event,
    Emitter<LocationListState> emit,
  ) async {
    final contractNames = <String, String>{};

    for (final location in state.locations) {
      final contract =
          await _contractRepository.getContractById(location.contractId);
      contractNames[location.contractId] = contract.name;
    }

    emit(
      state.copyWith(
        contractNames: contractNames,
      ),
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

  List<Location> _sortLocations(
    List<Location> locations,
    LocationListSort sort,
  ) {
    final sortedList = List<Location>.from(locations);

    switch (sort) {
      case LocationListSort.partieNrUp:
        sortedList.sort((a, b) => a.partieNr.compareTo(b.partieNr));
      case LocationListSort.partieNrDown:
        sortedList.sort((a, b) => b.partieNr.compareTo(a.partieNr));
      case LocationListSort.dateUp:
        sortedList.sort((a, b) => a.date.compareTo(b.date));
      case LocationListSort.dateDown:
        sortedList.sort((a, b) => b.date.compareTo(a.date));
    }

    return sortedList;
  }

  void _onSortChanged(
    LocationListSortChanged event,
    Emitter<LocationListState> emit,
  ) {
    final sortedLocations = _sortLocations(state.locations, event.sort);
    emit(
      state.copyWith(
        sort: event.sort,
        locations: sortedLocations,
      ),
    );
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    _locationSubscription?.cancel();
    _contractSubscription?.cancel();
    return super.close();
  }
}
