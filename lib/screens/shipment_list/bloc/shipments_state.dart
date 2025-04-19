part of 'shipments_bloc.dart';

enum ShipmentsStatus { initial, loading, success, failure }

final class ShipmentsState extends Equatable {
  ShipmentsState({
    this.status = ShipmentsStatus.initial,
    this.users = const {},
    this.sawmills = const {},
    this.shipments = const [],
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
  final Map<String, User> users;
  final Map<String, Sawmill> sawmills;
  final List<Shipment> shipments;
  final DateTime endDate;
  final DateTime startDate;
  final bool customDate;

  ShipmentsState copyWith({
    ShipmentsStatus? status,
    Map<String, User>? users,
    Map<String, Sawmill>? sawmills,
    List<Shipment>? shipments,
    DateTime? endDate,
    DateTime? startDate,
    bool? customDate,
  }) {
    return ShipmentsState(
      status: status ?? this.status,
      users: users ?? this.users,
      sawmills: sawmills ?? this.sawmills,
      shipments: shipments != null ? sortByDate(shipments) : this.shipments,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
      customDate: customDate ?? this.customDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users, 
        sawmills,
        shipments,
        endDate,
        startDate,
        customDate,
      ];
}
