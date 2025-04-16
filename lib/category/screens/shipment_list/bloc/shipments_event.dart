part of 'shipments_bloc.dart';

sealed class ShipmentsEvent extends Equatable {
  const ShipmentsEvent();

  @override
  List<Object> get props => [];
}

final class ShipmentsSubscriptionRequested extends ShipmentsEvent {
  const ShipmentsSubscriptionRequested();
}

final class ShipmentsShipmentUpdate extends ShipmentsEvent {
  const ShipmentsShipmentUpdate();
}

final class ShipmentsRefreshRequested extends ShipmentsEvent {
  const ShipmentsRefreshRequested();
}

final class ShipmentsShipmentDeleted extends ShipmentsEvent {
  const ShipmentsShipmentDeleted(this.shipment);

  final Shipment shipment;

  @override
  List<Object> get props => [shipment];
}

final class ShipmentsDateChanged extends ShipmentsEvent {
  const ShipmentsDateChanged(this.startDate, this.endDate);

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [startDate, endDate];
}

final class ShipmentsAutomaticDate extends ShipmentsEvent {
  const ShipmentsAutomaticDate();
}

final class ShipmentsUndoDeletionRequested extends ShipmentsEvent {
  const ShipmentsUndoDeletionRequested();
}
