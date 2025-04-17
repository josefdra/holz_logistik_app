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
    required ShipmentRepository shipmentRepository,
    required LocationRepository locationRepository,
  })  : _shipmentRepository = shipmentRepository,
        _locationRepository = locationRepository,
        super(ShipmentsState()) {
    on<ShipmentsSubscriptionRequested>(_onSubscriptionRequested);
    on<ShipmentsShipmentUpdate>(_onShipmentUpdate);
    on<ShipmentsRefreshRequested>(_onRefreshRequested);
    on<ShipmentsShipmentDeleted>(_onShipmentDeleted);
    on<ShipmentsDateChanged>(_onDateChanged);
    on<ShipmentsAutomaticDate>(_onAutomaticDate);
    on<ShipmentsUndoDeletionRequested>(_onUndoDeletionRequested);

    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDateChange();
    });
  }

  final ShipmentRepository _shipmentRepository;
  final LocationRepository _locationRepository;
  late final Timer _dateCheckTimer;
  final scrollController = ScrollController();

  late final StreamSubscription<Map<String, dynamic>>?
      _shipmentUpdateSubscription;

  void _checkDateChange() {
    final now = DateTime.now();

    if (now.isAfter(state.endDate) && !state.customDate) {
      add(const ShipmentsRefreshRequested());
    }
  }

  Future<void> _onSubscriptionRequested(
    ShipmentsSubscriptionRequested event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(state.copyWith(status: ShipmentsStatus.loading));
    add(const ShipmentsShipmentUpdate());

    _shipmentUpdateSubscription =
        _shipmentRepository.shipmentUpdates.listen((shipmentUpdate) {
      if (shipmentUpdate.isNotEmpty &&
          state.startDate.millisecondsSinceEpoch <=
              (shipmentUpdate['lastEdit'] as DateTime).millisecondsSinceEpoch &&
          (shipmentUpdate['lastEdit'] as DateTime).millisecondsSinceEpoch <=
              state.endDate.millisecondsSinceEpoch) {
        add(const ShipmentsShipmentUpdate());
      }
    });
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
    emit(state.copyWith(lastDeletedShipment: event.shipment));
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

  Future<void> _onUndoDeletionRequested(
    ShipmentsUndoDeletionRequested event,
    Emitter<ShipmentsState> emit,
  ) async {
    assert(
      state.lastDeletedShipment != null,
      'Last deleted shipment can not be null.',
    );

    final shipment = state.lastDeletedShipment!;
    await _shipmentRepository.saveShipment(shipment);


    await _locationRepository.addShipment(
      shipment.locationId,
      shipment.quantity,
      shipment.oversizeQuantity,
      shipment.pieceCount,
    );
  }

  @override
  Future<void> close() async {
    await _shipmentUpdateSubscription?.cancel();
    _dateCheckTimer.cancel();
    scrollController.dispose();
    return super.close();
  }
}
