part of 'location_details_bloc.dart';

enum LocationDetailsStatus { initial, loading, success, failure }

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
    double? currentQuantity,
    double? currentOversizeQuantity,
    int? currentPieceCount,
  })  : contract = contract ?? Contract.empty(),
        currentQuantity = currentQuantity ?? location.initialQuantity,
        currentOversizeQuantity =
            currentOversizeQuantity ?? location.initialOversizeQuantity,
        currentPieceCount = currentPieceCount ?? location.initialPieceCount;

  final LocationDetailsStatus status;
  final Location location;
  final Contract contract;
  final List<Sawmill> sawmills;
  final List<Sawmill> oversizeSawmills;
  final List<Shipment> shipments;
  final double currentQuantity;
  final double currentOversizeQuantity;
  final int currentPieceCount;

  LocationDetailsState copyWith({
    LocationDetailsStatus? status,
    Location? location,
    Contract? contract,
    List<Sawmill>? sawmills,
    List<Sawmill>? oversizeSawmills,
    List<Shipment>? shipments,
    double? currentQuantity,
    double? currentOversizeQuantity,
    int? currentPieceCount,
  }) {
    return LocationDetailsState(
      status: status ?? this.status,
      location: location ?? this.location,
      contract: contract ?? this.contract,
      sawmills: sawmills ?? this.sawmills,
      oversizeSawmills: oversizeSawmills ?? this.oversizeSawmills,
      shipments: shipments ?? this.shipments,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      currentOversizeQuantity:
          currentOversizeQuantity ?? this.currentOversizeQuantity,
      currentPieceCount: currentPieceCount ?? this.currentPieceCount,
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
      ];
}
