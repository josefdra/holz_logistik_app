part of 'notes_list_bloc.dart';

sealed class NotesListEvent extends Equatable {
  const NotesListEvent();

  @override
  List<Object> get props => [];
}

final class NotesListSubscriptionRequested extends NotesListEvent {
  const NotesListSubscriptionRequested();
}

final class NotesListNoteDeleted extends NotesListEvent {
  const NotesListNoteDeleted(this.note);

  final Note note;

  @override
  List<Object> get props => [note];
}

final class NotesListUndoDeletionRequested extends NotesListEvent {
  const NotesListUndoDeletionRequested();
}
