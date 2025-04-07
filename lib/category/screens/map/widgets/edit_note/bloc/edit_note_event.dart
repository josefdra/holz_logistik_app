part of 'edit_note_bloc.dart';

sealed class EditNoteEvent extends Equatable {
  const EditNoteEvent();

  @override
  List<Object> get props => [];
}

final class EditNoteTextChanged extends EditNoteEvent {
  const EditNoteTextChanged(
    this.text,
  );

  final String text;

  @override
  List<Object> get props => [text];
}

final class EditNoteSubmitted extends EditNoteEvent {
  const EditNoteSubmitted();
}
