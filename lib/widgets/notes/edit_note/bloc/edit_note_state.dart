part of 'edit_note_bloc.dart';

enum EditNoteStatus { initial, loading, ready, success, invalid, failure }

extension EditNoteStatusX on EditNoteStatus {
  bool get isLoadingOrSuccess => [
        EditNoteStatus.loading,
        EditNoteStatus.success,
      ].contains(this);
}

final class EditNoteState extends Equatable {
  EditNoteState({
    this.status = EditNoteStatus.initial,
    this.initialNote,
    this.text = '',
    this.validationErrors = const {},
    User? user,
  }) : user = user ?? User.empty();

  final EditNoteStatus status;
  final Note? initialNote;
  final String text;
  final Map<String, String?> validationErrors;
  final User user;

  bool get isNewNote => initialNote == null;

  EditNoteState copyWith({
    EditNoteStatus? status,
    Note? initialNote,
    String? text,
    Map<String, String?>? validationErrors,
    User? user,
  }) {
    return EditNoteState(
      status: status ?? this.status,
      initialNote: initialNote ?? this.initialNote,
      text: text ?? this.text,
      validationErrors: validationErrors ?? this.validationErrors,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialNote,
        text,
        validationErrors,
        user,
      ];
}
