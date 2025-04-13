import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'location_details_event.dart';
part 'location_details_state.dart';

class LocationDetailsBloc
    extends Bloc<LocationDetailsEvent, LocationDetailsState> {
  LocationDetailsBloc({
    required LocationRepository locationsRepository,
    required ContractRepository contractRepository,
    required SawmillRepository sawmillRepository,
    required ShipmentRepository shipmentRepository,
    required Location initialLocation,
  })  : _locationsRepository = locationsRepository,
        _contractRepository = contractRepository,
        _sawmillRepository = sawmillRepository,
        _shipmentRepository = shipmentRepository,
        super(
          LocationDetailsState(
            location: initialLocation,
          ),
        ) {
    on<LocationDetailsSubscriptionRequested>(_onSubscriptionRequested);
    on<LocationDetailsLocationUpdate>(_onLocationUpdate);
    on<LocationDetailsContractUpdate>(_onContractUpdate);
    on<LocationDetailsSawmillUpdate>(_onSawmillUpdate);
    on<LocationDetailsOversizeSawmillUpdate>(_onOversizeSawmillUpdate);
    on<LocationDetailsShipmentUpdate>(_onShipmentUpdate);
  }

  final LocationRepository _locationsRepository;
  final ContractRepository _contractRepository;
  final SawmillRepository _sawmillRepository;
  final ShipmentRepository _shipmentRepository;

  late final StreamSubscription<List<Location>>? _locationSubscription;
  late final StreamSubscription<Contract>? _contractSubscription;
  late final StreamSubscription<List<Sawmill>>? _sawmillSubscription;
  late final StreamSubscription<List<Sawmill>>? _oversizeSawmillSubscription;
  late final StreamSubscription<List<Shipment>>? _shipmentSubscription;

  void _onSubscriptionRequested(
    LocationDetailsSubscriptionRequested event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(status: LocationDetailsStatus.loading));

    try {
      _locationSubscription = _locationsRepository.activeLocations
          .map(
            (locations) => locations
                .where((location) => location.id == state.location.id)
                .toList(),
          )
          .listen(
            (filteredLocations) =>
                add(LocationDetailsLocationUpdate(filteredLocations.first)),
          );

      _contractSubscription = _contractRepository.activeContracts
          .map(
            (contractMap) => contractMap.containsKey(state.location.contractId)
                ? contractMap[state.location.contractId]!
                : Contract.empty(),
          )
          .listen(
            (contract) => add(
              LocationDetailsContractUpdate(contract),
            ),
          );

      _sawmillSubscription = _sawmillRepository.sawmills.map(
        (sawmills) {
          final sawmillIds = state.location.sawmillIds;
          if (sawmillIds == null || sawmillIds.isEmpty) {
            return <Sawmill>[];
          }
          return sawmills
              .where(
                (sawmill) => state.location.sawmillIds!.contains(sawmill.id),
              )
              .toList();
        },
      ).listen(
        (filteredSawmills) =>
            add(LocationDetailsSawmillUpdate(filteredSawmills)),
      );

      _oversizeSawmillSubscription = _sawmillRepository.sawmills.map(
        (sawmills) {
          final sawmillIds = state.location.sawmillIds;
          if (sawmillIds == null || sawmillIds.isEmpty) {
            return <Sawmill>[];
          }
          return sawmills
              .where(
                (sawmill) =>
                    state.location.oversizeSawmillIds!.contains(sawmill.id),
              )
              .toList();
        },
      ).listen(
        (filteredOversizeSawmills) => add(
          LocationDetailsOversizeSawmillUpdate(filteredOversizeSawmills),
        ),
      );

      _shipmentSubscription = _shipmentRepository.shipmentsByLocation
          .map(
            (shipmentMap) => shipmentMap.containsKey(state.location.id)
                ? shipmentMap[state.location.id]!
                : const <Shipment>[],
          )
          .listen(
            (filteredShipments) =>
                add(LocationDetailsShipmentUpdate(filteredShipments)),
          );

      emit(
        state.copyWith(
          status: LocationDetailsStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationDetailsStatus.failure,
        ),
      );
    }
  }

  void _refreshSawmills() {
    final sawmillIds = state.location.sawmillIds;
    if (sawmillIds == null || sawmillIds.isEmpty) {
      add(const LocationDetailsSawmillUpdate(<Sawmill>[]));
      return;
    }

    _sawmillRepository.sawmills.first.then((sawmills) {
      final filteredSawmills = sawmills
          .where((sawmill) => state.location.sawmillIds!.contains(sawmill.id))
          .toList();
      add(LocationDetailsSawmillUpdate(filteredSawmills));
    });
  }

  void _refreshOversizeSawmills() {
    final oversizeSawmillIds = state.location.oversizeSawmillIds;
    if (oversizeSawmillIds == null || oversizeSawmillIds.isEmpty) {
      add(const LocationDetailsOversizeSawmillUpdate(<Sawmill>[]));
      return;
    }

    _sawmillRepository.sawmills.first.then((sawmills) {
      final filteredOversizeSawmills = sawmills
          .where((sawmill) =>
              state.location.oversizeSawmillIds!.contains(sawmill.id))
          .toList();
      add(LocationDetailsOversizeSawmillUpdate(filteredOversizeSawmills));
    });
  }

  void _refreshContract() {
    final contractId = state.location.contractId;

    _contractRepository.activeContracts.first.then((contractMap) {
      final contract = contractMap.containsKey(contractId)
          ? contractMap[contractId]!
          : Contract.empty();
      add(LocationDetailsContractUpdate(contract));
    });
  }

  void _onLocationUpdate(
    LocationDetailsLocationUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(location: event.location));
    _refreshContract();
    _refreshSawmills();
    _refreshOversizeSawmills();
  }

  void _onContractUpdate(
    LocationDetailsContractUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(contract: event.contract));
  }

  void _onSawmillUpdate(
    LocationDetailsSawmillUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(sawmills: event.sawmills));
  }

  void _onOversizeSawmillUpdate(
    LocationDetailsOversizeSawmillUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(oversizeSawmills: event.oversizeSawmills));
  }

  void _onShipmentUpdate(
    LocationDetailsShipmentUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(
      state.copyWith(shipments: event.shipments),
    );
  }

  @override
  Future<void> close() async {
    await _locationSubscription?.cancel();
    await _contractSubscription?.cancel();
    await _sawmillSubscription?.cancel();
    await _oversizeSawmillSubscription?.cancel();
    await _shipmentSubscription?.cancel();
    return super.close();
  }
}
