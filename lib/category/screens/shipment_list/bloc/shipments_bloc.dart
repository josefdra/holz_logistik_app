import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/shipment_list/shipments.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'shipments_event.dart';
part 'shipments_state.dart';

class ShipmentsBloc extends Bloc<ShipmentsEvent, ShipmentsState> {
  ShipmentsBloc({
    required ShipmentRepository shipmentRepository,
  })  : _shipmentRepository = shipmentRepository,
        super(const ShipmentsState()) {
    on<ShipmentsSubscriptionRequested>(_onSubscriptionRequested);
    on<ShipmentsShipmentDeleted>(_onShipmentDeleted);
    on<ShipmentsUndoDeletionRequested>(_onUndoDeletionRequested);
  }

  final ShipmentRepository _shipmentRepository;

  Future<void> _onSubscriptionRequested(
    ShipmentsSubscriptionRequested event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(state.copyWith(status: ShipmentsStatus.loading));

    await emit.forEach<List<Shipment>>(
      _shipmentRepository.allShipments,
      onData: (shipments) => state.copyWith(
        status: ShipmentsStatus.success,
        shipments: shipments,
      ),
      onError: (_, __) => state.copyWith(
        status: ShipmentsStatus.failure,
      ),
    );
  }

  Future<void> _onShipmentDeleted(
    ShipmentsShipmentDeleted event,
    Emitter<ShipmentsState> emit,
  ) async {
    emit(state.copyWith(lastDeletedShipment: event.shipment));
    await _shipmentRepository.deleteShipment(
      id: event.shipment.id,
      locationId: event.shipment.locationId,
    );
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
    emit(state.copyWith());
    await _shipmentRepository.saveShipment(shipment);
  }
}
