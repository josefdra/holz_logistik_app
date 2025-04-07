part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

final class MapSubscriptionRequested extends MapEvent {
  const MapSubscriptionRequested();
}

final class MapNoteDeleted extends MapEvent {
  const MapNoteDeleted(this.note);

  final Note note;

  @override
  List<Object> get props => [note];
}

final class MapUndoDeletionRequested extends MapEvent {
  const MapUndoDeletionRequested();
}
