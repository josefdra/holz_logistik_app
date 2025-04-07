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

  final int filter = 1;

  @override
  List<Object> get props => [filter];
}

class MapCenterToPosition extends MapEvent {
  const MapCenterToPosition();

  final int filter = 1;

  @override
  List<Object> get props => [filter];
}

class MapToggleAddMarkerMode extends MapEvent {
  const MapToggleAddMarkerMode();

  final int filter = 1;

  @override
  List<Object> get props => [filter];
}

class MapToggleMarkerInfoMode extends MapEvent {
  const MapToggleMarkerInfoMode();

  final int filter = 1;

  @override
  List<Object> get props => [filter];
}
