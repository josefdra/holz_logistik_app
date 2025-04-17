part of 'edit_note_bloc.dart';

sealed class EditNoteEvent extends Equatable {
  const EditNoteEvent();

  @override
  List<Object> get props => [];
}

final class EditNoteSubscriptionRequested extends EditNoteEvent {
  const EditNoteSubscriptionRequested();
}

final class EditNoteTextChanged extends EditNoteEvent {
  const EditNoteTextChanged(
    this.text, {
    this.fieldName = 'text',
  });

  final String fieldName;
  final String text;

  @override
  List<Object> get props => [text];
}

final class EditNoteUserUpdate extends EditNoteEvent {
  const EditNoteUserUpdate(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

final class EditNoteSubmitted extends EditNoteEvent {
  const EditNoteSubmitted();
}
