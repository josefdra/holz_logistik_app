part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

final class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.addMarkerMode = false,
    this.showInfoMode = false,
    this.markers = const [],
    this.newMarker,
  });

  final MapStatus status;
  final bool addMarkerMode;
  final bool showInfoMode;
  final List<Marker> markers;
  final Marker? newMarker;

  MapState copyWith({
    MapStatus? status,
    bool? addMarkerMode,
    bool? showInfoMode,
    List<Marker>? markers,
    Marker? newMarker,
  }) {
    return MapState(
      status: status ?? this.status,
      addMarkerMode: addMarkerMode ?? this.addMarkerMode,
      showInfoMode: showInfoMode ?? this.showInfoMode,
      markers: markers ?? this.markers,
      newMarker: newMarker ?? this.newMarker,
    );
  }

  @override
  List<Object?> get props => [
        status,
        addMarkerMode,
        showInfoMode,
        markers,
        newMarker,
      ];
}
