part of 'edit_note_bloc.dart';

enum EditNoteStatus { initial, loading, success, invalid, failure }

extension EditNoteStatusX on EditNoteStatus {
  bool get isLoadingOrSuccess => [
        EditNoteStatus.loading,
        EditNoteStatus.success,
      ].contains(this);
}

final class EditNoteState extends Equatable {
  const EditNoteState({
    this.status = EditNoteStatus.initial,
    this.initialNote,
    this.text = '',
    this.validationErrors = const {},
  });

  final EditNoteStatus status;
  final Note? initialNote;
  final String text;
  final Map<String, String?> validationErrors;

  bool get isNewNote => initialNote == null;

  EditNoteState copyWith({
    EditNoteStatus? status,
    Note? initialNote,
    String? text,
    Map<String, String?>? validationErrors,
  }) {
    return EditNoteState(
      status: status ?? this.status,
      initialNote: initialNote ?? this.initialNote,
      text: text ?? this.text,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialNote,
        text,
        validationErrors,
      ];
}
