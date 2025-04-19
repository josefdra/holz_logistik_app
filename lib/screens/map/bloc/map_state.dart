part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

final class MapState extends Equatable {
  MapState({
    this.status = MapStatus.initial,
    this.addMarkerMode = false,
    this.showInfoMode = false,
    this.locations = const [],
    this.sawmills = const {},
    this.userLocation,
    this.trackingMode = true,
    this.newMarkerPosition,
    User? user,
  })  : user = user ?? User.empty();

  final MapStatus status;
  final bool addMarkerMode;
  final bool showInfoMode;
  final List<Location> locations;
  final Map<String, Sawmill> sawmills;
  final LatLng? userLocation;
  final bool trackingMode;
  final LatLng? newMarkerPosition;
  final User user;

  MapState copyWith({
    MapStatus? status,
    bool? addMarkerMode,
    bool? showInfoMode,
    List<Location>? locations,
    Map<String, Sawmill>? sawmills,
    LatLng? userLocation,
    Marker? userLocationMarker,
    bool? trackingMode,
    LatLng? newMarkerPosition,
    User? user,
  }) {
    return MapState(
      status: status ?? this.status,
      addMarkerMode: addMarkerMode ?? this.addMarkerMode,
      showInfoMode: showInfoMode ?? this.showInfoMode,
      locations: locations ?? this.locations,
      sawmills: sawmills ?? this.sawmills,
      userLocation: userLocation ?? this.userLocation,
      trackingMode: trackingMode ?? this.trackingMode,
      newMarkerPosition: newMarkerPosition ?? this.newMarkerPosition,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        status,
        addMarkerMode,
        showInfoMode,
        locations,
        sawmills,
        userLocation,
        trackingMode,
        newMarkerPosition,
        user,
      ];
}
