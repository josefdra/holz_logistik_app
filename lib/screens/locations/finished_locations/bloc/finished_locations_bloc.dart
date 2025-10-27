import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/locations/location_list_sort.dart';
import 'package:holz_logistik/models/models.dart';
import 'package:holz_logistik/screens/locations/location_list/location_list.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'finished_locations_event.dart';
part 'finished_locations_state.dart';

class FinishedLocationsBloc
    extends Bloc<FinishedLocationsEvent, FinishedLocationsState> {
  FinishedLocationsBloc({
    required LocationRepository locationRepository,
    required ContractRepository contractRepository,
  })  : _locationRepository = locationRepository,
        _contractRepository = contractRepository,
        super(FinishedLocationsState()) {
    on<FinishedLocationsSubscriptionRequested>(_onSubscriptionRequested);
    on<FinishedLocationsLocationUpdate>(_onLocationUpdate);
    on<FinishedLocationsRefreshRequested>(_onRefreshRequested);
    on<FinishedLocationsDateChanged>(_onDateChanged);
    on<FinishedLocationsAutomaticDate>(_onAutomaticDate);
    on<FinishedLocationsLocationDeleted>(_onLocationDeleted);
    on<FinishedLocationListSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(
        const Duration(milliseconds: 300),
      ),
    );
    on<FinishedLocationListSortChanged>(_onSortChanged);

    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDateChange();
    });
  }

  final LocationRepository _locationRepository;
  final ContractRepository _contractRepository;
  late final Timer _dateCheckTimer;
  final scrollController = ScrollController();

  late final StreamSubscription<Location>? _locationUpdateSubscription;

  void _checkDateChange() {
    final now = DateTime.now();

    if (now.isAfter(state.endDate) && !state.customDate) {
      add(const FinishedLocationsRefreshRequested());
    }
  }

  Future<void> _onSubscriptionRequested(
    FinishedLocationsSubscriptionRequested event,
    Emitter<FinishedLocationsState> emit,
  ) async {
    emit(state.copyWith(status: FinishedLocationsStatus.loading));
    add(const FinishedLocationsLocationUpdate());

    _locationUpdateSubscription =
        _locationRepository.locationUpdates.listen((location) {
      if (state.startDate.millisecondsSinceEpoch <=
              location.date.millisecondsSinceEpoch &&
          location.date.millisecondsSinceEpoch <=
              state.endDate.millisecondsSinceEpoch) {
        add(const FinishedLocationsLocationUpdate());
      }
    });
  }

  Future<void> _onLocationUpdate(
    FinishedLocationsLocationUpdate event,
    Emitter<FinishedLocationsState> emit,
  ) async {
    final locations = await _locationRepository.getFinishedLocationsByDate(
      state.startDate,
      state.endDate,
    );
    final sortedLocations = _sortLocations(locations, state.sort);

    final contractNames = <String, String>{};

    for (final location in locations) {
      final contract =
          await _contractRepository.getContractById(location.contractId);
      contractNames[location.contractId] = contract.name;
    }

    emit(
      state.copyWith(
        status: FinishedLocationsStatus.success,
        locations: sortedLocations,
        contractNames: contractNames,
      ),
    );
  }

  Future<void> _onRefreshRequested(
    FinishedLocationsRefreshRequested event,
    Emitter<FinishedLocationsState> emit,
  ) async {
    final endDate = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
    final startDate = endDate.subtract(const Duration(days: 365));

    emit(
      state.copyWith(
        startDate: startDate,
        endDate: endDate,
      ),
    );

    add(const FinishedLocationsLocationUpdate());
  }

  Future<void> _onDateChanged(
    FinishedLocationsDateChanged event,
    Emitter<FinishedLocationsState> emit,
  ) async {
    emit(
      state.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
        customDate: true,
      ),
    );

    add(const FinishedLocationsLocationUpdate());
  }

  Future<void> _onAutomaticDate(
    FinishedLocationsAutomaticDate event,
    Emitter<FinishedLocationsState> emit,
  ) async {
    emit(state.copyWith(customDate: false));

    add(const FinishedLocationsRefreshRequested());
  }

  void _onLocationDeleted(
    FinishedLocationsLocationDeleted event,
    Emitter<FinishedLocationsState> emit,
  ) {
    _locationRepository.deleteLocation(
      id: event.location.id,
      done: event.location.done,
    );

    emit(state.copyWith(status: FinishedLocationsStatus.success));
  }

  void _onSearchQueryChanged(
    FinishedLocationListSearchQueryChanged event,
    Emitter<FinishedLocationsState> emit,
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
    FinishedLocationListSortChanged event,
    Emitter<FinishedLocationsState> emit,
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
    _locationUpdateSubscription?.cancel();
    _dateCheckTimer.cancel();
    return super.close();
  }
}
