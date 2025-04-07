part of 'edit_note_bloc.dart';

enum EditNoteStatus { initial, loading, success, failure }

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
    DateTime? lastEdit,
    this.text = '',
    User? user,
    this.comments = const [],
  })  : lastEdit = lastEdit ?? DateTime.now(),
        user = user ?? User.empty();

  final EditNoteStatus status;
  final Note? initialNote;
  final DateTime lastEdit;
  final String text;
  final User user;
  final List<Comment> comments;

  bool get isNewNote => initialNote == null;

  EditNoteState copyWith({
    EditNoteStatus? status,
    Note? initialNote,
    DateTime? lastEdit,
    String? text,
    User? user,
    List<Comment>? comments,
  }) {
    return EditNoteState(
      status: status ?? this.status,
      initialNote: initialNote ?? this.initialNote,
      lastEdit: lastEdit ?? this.lastEdit,
      text: text ?? this.text,
      user: user ?? this.user,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialNote,
        lastEdit,
        text,
        user,
        comments,
      ];
}
