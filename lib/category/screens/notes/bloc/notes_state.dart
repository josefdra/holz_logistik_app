part of 'notes_bloc.dart';

enum NotesStatus { initial, loading, success, failure }

final class NotesState extends Equatable {
  const NotesState({
    this.status = NotesStatus.initial,
    this.notes = const [],
    this.lastDeletedNote,
  });

  final NotesStatus status;
  final List<Note> notes;
  final Note? lastDeletedNote;

  NotesState copyWith({
    NotesStatus? status,
    List<Note>? notes,
    Note? lastDeletedNote,
  }) {
    return NotesState(
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
