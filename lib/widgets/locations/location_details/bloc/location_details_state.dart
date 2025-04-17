part of 'location_details_bloc.dart';

enum LocationDetailsStatus { initial, loading, success, close, failure }

extension LocationDetailsStatusX on LocationDetailsStatus {
  bool get isLoadingOrSuccess => [
        LocationDetailsStatus.loading,
        LocationDetailsStatus.success,
      ].contains(this);
}

final class LocationDetailsState extends Equatable {
  LocationDetailsState({
    required this.location,
    this.status = LocationDetailsStatus.initial,
    Contract? contract,
    this.sawmills = const [],
    this.oversizeSawmills = const [],
    this.shipments = const [],
    User? user,
  })  : contract = contract ?? Contract.empty(),
        user = user ?? User.empty();

  final LocationDetailsStatus status;
  final Location location;
  final Contract contract;
  final List<Sawmill> sawmills;
  final List<Sawmill> oversizeSawmills;
  final List<Shipment> shipments;
  final User user;

  LocationDetailsState copyWith({
    LocationDetailsStatus? status,
    Location? location,
    Contract? contract,
    List<Sawmill>? sawmills,
    List<Sawmill>? oversizeSawmills,
    List<Shipment>? shipments,
    User? user,
  }) {
    return LocationDetailsState(
      status: status ?? this.status,
      location: location ?? this.location,
      contract: contract ?? this.contract,
      sawmills: sawmills ?? this.sawmills,
      oversizeSawmills: oversizeSawmills ?? this.oversizeSawmills,
      shipments: shipments ?? this.shipments,
      user: user ?? this.user,
    );
  }

  @override
  List<Object> get props => [
        status,
        location,
        contract,
        sawmills,
        oversizeSawmills,
        shipments,
        user,
      ];
}
