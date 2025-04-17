part of 'shipments_bloc.dart';

enum ShipmentsStatus { initial, loading, success, failure }

final class ShipmentsState extends Equatable {
  ShipmentsState({
    this.status = ShipmentsStatus.initial,
    this.shipments = const [],
    this.lastDeletedShipment,
    DateTime? endDate,
    DateTime? startDate,
    this.customDate = false,
  })  : endDate = endDate ??
            DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
        startDate = startDate ??
            DateTime.now()
                .copyWith(hour: 23, minute: 59, second: 59)
                .subtract(const Duration(days: 32));

  final ShipmentsStatus status;
  final List<Shipment> shipments;
  final Shipment? lastDeletedShipment;
  final DateTime endDate;
  final DateTime startDate;
  final bool customDate;

  ShipmentsState copyWith({
    ShipmentsStatus? status,
    List<Shipment>? shipments,
    Shipment? lastDeletedShipment,
    DateTime? endDate,
    DateTime? startDate,
    bool? customDate,
  }) {
    return ShipmentsState(
      status: status ?? this.status,
      shipments: shipments != null ? sortByDate(shipments) : this.shipments,
      lastDeletedShipment: lastDeletedShipment ?? this.lastDeletedShipment,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
      customDate: customDate ?? this.customDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        shipments,
        lastDeletedShipment,
        endDate,
        startDate,
        customDate,
      ];
}
