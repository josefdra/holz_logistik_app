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
    this.photos = const [],
    this.userNames = const {},
    this.sawmillNames = const {},
    User? user,
  })  : contract = contract ?? Contract(),
        user = user ?? User();

  final LocationDetailsStatus status;
  final Location location;
  final Contract contract;
  final List<Sawmill> sawmills;
  final List<Sawmill> oversizeSawmills;
  final List<Shipment> shipments;
  final List<Photo> photos;
  final Map<String, String> userNames;
  final Map<String, String> sawmillNames;
  final User user;

  LocationDetailsState copyWith({
    LocationDetailsStatus? status,
    Location? location,
    Contract? contract,
    List<Sawmill>? sawmills,
    List<Sawmill>? oversizeSawmills,
    List<Shipment>? shipments,
    List<Photo>? photos,
    Map<String, String>? userNames,
    Map<String, String>? sawmillNames,
    User? user,
  }) {
    return LocationDetailsState(
      status: status ?? this.status,
      location: location ?? this.location,
      contract: contract ?? this.contract,
      sawmills: sawmills ?? this.sawmills,
      oversizeSawmills: oversizeSawmills ?? this.oversizeSawmills,
      shipments: shipments != null ? sortByDate(shipments) : this.shipments,
      photos: photos != null ? sortByDate(photos) : this.photos,
      userNames: userNames ?? this.userNames,
      sawmillNames: sawmillNames ?? this.sawmillNames,
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
        photos,
        userNames,
        sawmillNames,
        user,
      ];
}
