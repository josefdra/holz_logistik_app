part of 'shipments_bloc.dart';

enum ShipmentsStatus { initial, loading, success, failure }

final class ShipmentsState extends Equatable {
  const ShipmentsState({
    this.status = ShipmentsStatus.initial,
    this.shipments = const [],
    this.lastDeletedShipment,
  });

  final ShipmentsStatus status;
  final List<Shipment> shipments;
  final Shipment? lastDeletedShipment;

  ShipmentsState copyWith({
    ShipmentsStatus? status,
    List<Shipment>? shipments,
    Shipment? lastDeletedShipment,
  }) {
    return ShipmentsState(
      status: status ?? this.status,
      shipments: shipments != null ? sortByLastEdit(shipments) : this.shipments,
      lastDeletedShipment: lastDeletedShipment ?? this.lastDeletedShipment,
    );
  }

  @override
  List<Object?> get props => [
        status,
        shipments,
        lastDeletedShipment,
      ];
}
