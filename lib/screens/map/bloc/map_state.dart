part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

final class MapState extends Equatable {
  MapState({
    this.status = MapStatus.initial,
    this.addMarkerMode = false,
    this.showInfoMode = false,
    this.locations = const [],
    this.sawmills = const {},
    this.contractNames = const {},
    this.userLocation,
    this.trackingMode = true,
    this.newMarkerPosition,
    this.mapReady = false,
    User? user,
  })  : user = user ?? User();

  final MapStatus status;
  final bool addMarkerMode;
  final bool showInfoMode;
  final List<Location> locations;
  final Map<String, Sawmill> sawmills;
  final Map<String, String> contractNames;
  final LatLng? userLocation;
  final bool trackingMode;
  final LatLng? newMarkerPosition;
  final User user;
  final bool mapReady;

  MapState copyWith({
    MapStatus? status,
    bool? addMarkerMode,
    bool? showInfoMode,
    List<Location>? locations,
    Map<String, Sawmill>? sawmills,
    Map<String, String>? contractNames,
    LatLng? userLocation,
    Marker? userLocationMarker,
    bool? trackingMode,
    LatLng? newMarkerPosition,
    User? user,
    bool? mapReady,
  }) {
    return MapState(
      status: status ?? this.status,
      addMarkerMode: addMarkerMode ?? this.addMarkerMode,
      showInfoMode: showInfoMode ?? this.showInfoMode,
      locations: locations != null ? sortByDate(locations) : this.locations,
      sawmills: sawmills ?? this.sawmills,
      contractNames: contractNames ?? this.contractNames,
      userLocation: userLocation ?? this.userLocation,
      trackingMode: trackingMode ?? this.trackingMode,
      newMarkerPosition: newMarkerPosition ?? this.newMarkerPosition,
      user: user ?? this.user,
      mapReady: mapReady ?? this.mapReady,
    );
  }

  @override
  List<Object?> get props => [
        status,
        addMarkerMode,
        showInfoMode,
        locations,
        sawmills,
        contractNames,
        userLocation,
        trackingMode,
        newMarkerPosition,
        user,
        mapReady,
      ];
}
