part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

final class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.notes = const [],
    this.lastDeletedNote,
  });

  final MapStatus status;
  final List<Note> notes;
  final Note? lastDeletedNote;

  MapState copyWith({
    MapStatus? status,
    List<Note>? notes,
    Note? lastDeletedNote,
  }) {
    return MapState(
      status: status ?? this.status,
      notes: notes != null ? sortByLastEdit(notes) : this.notes,
      lastDeletedNote: lastDeletedNote ?? this.lastDeletedNote,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notes,
        lastDeletedNote,
      ];
}
