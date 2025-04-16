part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

final class NotesSubscriptionRequested extends NotesEvent {
  const NotesSubscriptionRequested();
}

final class NotesNoteDeleted extends NotesEvent {
  const NotesNoteDeleted(this.note);

  final Note note;

  @override
  List<Object> get props => [note];
}

final class NotesUndoDeletionRequested extends NotesEvent {
  const NotesUndoDeletionRequested();
}
