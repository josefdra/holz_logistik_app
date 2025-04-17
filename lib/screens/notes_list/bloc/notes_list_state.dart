part of 'notes_list_bloc.dart';

enum NotesListStatus { initial, loading, success, failure }

final class NotesListState extends Equatable {
  const NotesListState({
    this.status = NotesListStatus.initial,
    this.notes = const [],
    this.lastDeletedNote,
  });

  final NotesListStatus status;
  final List<Note> notes;
  final Note? lastDeletedNote;

  NotesListState copyWith({
    NotesListStatus? status,
    List<Note>? notes,
    Note? lastDeletedNote,
  }) {
    return NotesListState(
      status: status ?? this.status,
      notes: notes != null ? sortByDate(notes) : this.notes,
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
