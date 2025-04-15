part of 'shipments_bloc.dart';

sealed class ShipmentsEvent extends Equatable {
  const ShipmentsEvent();

  @override
  List<Object> get props => [];
}

final class ShipmentsSubscriptionRequested extends ShipmentsEvent {
  const ShipmentsSubscriptionRequested();
}

final class ShipmentsShipmentDeleted extends ShipmentsEvent {
  const ShipmentsShipmentDeleted(this.shipment);

  final Shipment shipment;

  @override
  List<Object> get props => [shipment];
}

final class ShipmentsUndoDeletionRequested extends ShipmentsEvent {
  const ShipmentsUndoDeletionRequested();
}
