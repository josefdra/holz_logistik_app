part of 'location_details_bloc.dart';

enum LocationDetailsStatus { initial, loading, success, failure }

extension LocationDetailsStatusX on LocationDetailsStatus {
  bool get isLoadingOrSuccess => [
        LocationDetailsStatus.loading,
        LocationDetailsStatus.success,
      ].contains(this);
}

final class LocationDetailsState extends Equatable {
  const LocationDetailsState({
    required this.location,
    this.status = LocationDetailsStatus.initial,
    this.sawmills = const [],
    this.oversizeSawmills = const [],
    this.shipments = const [],
  });

  final LocationDetailsStatus status;
  final Location location;
  final List<Sawmill> sawmills;
  final List<Sawmill> oversizeSawmills;
  final List<Shipment> shipments;

  LocationDetailsState copyWith({
    LocationDetailsStatus? status,
    Location? location,
    List<Sawmill>? sawmills,
    List<Sawmill>? oversizeSawmills,
    List<Shipment>? shipments,
  }) {
    return LocationDetailsState(
      status: status ?? this.status,
      location: location ?? this.location,
      sawmills: sawmills ?? this.sawmills,
      oversizeSawmills: oversizeSawmills ?? this.oversizeSawmills,
      shipments: shipments ?? this.shipments,
    );
  }

  @override
  List<Object> get props => [
        status,
        location,
        sawmills,
        oversizeSawmills,
        shipments,
      ];
}
