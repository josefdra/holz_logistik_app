import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/general/sort.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'shipments_event.dart';
part 'shipments_state.dart';

class ShipmentsBloc extends Bloc<ShipmentsEvent, ShipmentsState> {
  ShipmentsBloc({
    required UserRepository userRepository,
    required SawmillRepository sawmillRepository,
    required ShipmentRepository shipmentRepository,
    required LocationRepository locationRepository,
    required ContractRepository contractRepository,
  })  : _userRepository = userRepository,
        _sawmillRepository = sawmillRepository,
        _shipmentRepository = shipmentRepository,
        _locationRepository = locationRepository,
        _contractRepository = contractRepository,
        super(ShipmentsState()) {
    on<ShipmentsSubscriptionRequested>(_onSubscriptionRequested);
    on<ShipmentsUsersUpdate>(_onUsersUpdate);
    on<ShipmentsSawmillsUpdate>(_onSawmillsUpdate);
    on<ShipmentsShipmentUpdate>(_onShipmentUpdate);
    on<ShipmentsRefreshRequested>(_onRefreshRequested);
    on<ShipmentsShipmentDeleted>(_onShipmentDeleted);
    on<ShipmentsDateChanged>(_onDateChanged);
    on<ShipmentsAutomaticDate>(_onAutomaticDate);

    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDateChange();
    });
  }

  final UserRepository _userRepository;
  final SawmillRepository _sawmillRepository;
  final ShipmentRepository _shipmentRepository;
  final LocationRepository _locationRepository;
  final ContractRepository _contractRepository;
  late final Timer _dateCheckTimer;
  final scrollController = ScrollController();

  late final StreamSubscription<Map<String, User>>? _userUpdateSubscription;
  late final StreamSubscription<Map<String, Sawmill>>?
      _sawmillUpdateSubscription;
  late final StreamSubscription<Shipment>? _shipmentUpdateSubscription;

  void _checkDateChange() {
    final now = DateTime.now();

    if (now.isAfter(state.endDate) && !state.customDate) {
      add(const ShipmentsRefreshRequested());
    }
  }

  void _onSubscriptionRequested(
    ShipmentsSubscriptionRequested event,
    Emitter<ShipmentsState> emit,
  ) {
    emit(state.copyWith(status: ShipmentsStatus.loading));
    add(const ShipmentsShipmentUpdate());

    _userUpdateSubscription = _userRepository.users
        .listen((users) => add(ShipmentsUsersUpdate(users)));

    _sawmillUpdateSubscription = _sawmillRepository.sawmills
        .listen((sawmills) => add(ShipmentsSawmillsUpdate(sawmills)));

    _shipmentUpdateSubscription =
        _shipmentRepository.shipmentUpdates.listen((shipment) {
      if (state.startDate.millisecondsSinceEpoch <=
              shipment.date.millisecondsSinceEpoch &&
          shipment.date.millisecondsSinceEpoch <=
              state.endDate.millisecondsSinceEpoch) {
        add(const ShipmentsShipmentUpdate());
      }
    });
  }

  Future<void> _onUsersUpdate(
    ShipmentsUsersUpdate event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ShipmentsStatus.success,
        users: event.users,
      ),
    );
  }

  Future<void> _onSawmillsUpdate(
    ShipmentsSawmillsUpdate event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ShipmentsStatus.success,
        sawmills: event.sawmills,
      ),
    );
  }

  Future<void> _onShipmentUpdate(
    ShipmentsShipmentUpdate event,
    Emitter<ShipmentsState> emit,
  ) async {
    final shipments = await _shipmentRepository.getShipmentsByDate(
      state.startDate,
      state.endDate,
    );

    emit(
      state.copyWith(
        status: ShipmentsStatus.success,
        shipments: shipments,
      ),
    );
  }

  Future<void> _onRefreshRequested(
    ShipmentsRefreshRequested event,
    Emitter<ShipmentsState> emit,
  ) async {
    final endDate = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
    final startDate = endDate.subtract(const Duration(days: 32));

    emit(
      state.copyWith(
        startDate: startDate,
        endDate: endDate,
      ),
    );

    add(const ShipmentsShipmentUpdate());
  }

  Future<void> _onShipmentDeleted(
    ShipmentsShipmentDeleted event,
    Emitter<ShipmentsState> emit,
  ) async {
    final locationId = event.shipment.locationId;

    await _shipmentRepository.deleteShipment(
      id: event.shipment.id,
      locationId: locationId,
    );

    final shipments =
        await _shipmentRepository.getShipmentsByLocation(locationId);

    late final bool started;
    if (shipments.isEmpty) {
      started = false;
    } else {
      started = true;
    }

    await _locationRepository.removeShipment(
      locationId,
      event.shipment.quantity,
      event.shipment.oversizeQuantity,
      event.shipment.pieceCount,
      started: started,
    );

    final contract =
        await _contractRepository.getContractById(event.shipment.contractId);

    await _contractRepository.saveContract(
      contract.copyWith(
        shippedQuantity: contract.shippedQuantity - event.shipment.quantity,
      ),
    );
  }

  Future<void> _onDateChanged(
    ShipmentsDateChanged event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(
      state.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
        customDate: true,
      ),
    );

    add(const ShipmentsShipmentUpdate());
  }

  Future<void> _onAutomaticDate(
    ShipmentsAutomaticDate event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(state.copyWith(customDate: false));

    add(const ShipmentsRefreshRequested());
  }

  @override
  Future<void> close() async {
    await _userUpdateSubscription?.cancel();
    await _sawmillUpdateSubscription?.cancel();
    await _shipmentUpdateSubscription?.cancel();
    _dateCheckTimer.cancel();
    scrollController.dispose();
    return super.close();
  }
}
