part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

final class MapSubscriptionRequested extends MapEvent {
  const MapSubscriptionRequested();
}

class MapResetMapRotation extends MapEvent {
  const MapResetMapRotation();
}

class MapAuthenticationUpdate extends MapEvent {
  const MapAuthenticationUpdate(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class MapCenterToPosition extends MapEvent {
  const MapCenterToPosition();
}

class MapToggleAddMarkerMode extends MapEvent {
  const MapToggleAddMarkerMode();
}

class MapToggleMarkerInfoMode extends MapEvent {
  const MapToggleMarkerInfoMode();
}

class MapLocationUpdated extends MapEvent {
  const MapLocationUpdated({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => [latitude, longitude];
}

class MapDisableTrackingMode extends MapEvent {
  const MapDisableTrackingMode();
}

class MapMapTap extends MapEvent {
  const MapMapTap({required this.position});

  final LatLng position;

  @override
  List<Object> get props => [position];
}
