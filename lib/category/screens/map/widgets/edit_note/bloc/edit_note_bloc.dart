import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/api/api.dart';
import 'package:holz_logistik_backend/repository/note_repository.dart';

part 'edit_note_event.dart';
part 'edit_note_state.dart';

class EditNoteBloc extends Bloc<EditNoteEvent, EditNoteState> {
  EditNoteBloc({
    required NoteRepository notesRepository,
    required User authenticatedUser,
    required Note? initialNote,
  })  : _notesRepository = notesRepository,
        _authenticatedUser = authenticatedUser,
        super(
          EditNoteState(
            initialNote: initialNote,
            text: initialNote?.text ?? '',
            user: initialNote?.user ?? User.empty(),
            comments: initialNote?.comments ?? const [],
          ),
        ) {
    on<EditNoteTextChanged>(_onTextChanged);
    on<EditNoteSubmitted>(_onSubmitted);
  }

  final NoteRepository _notesRepository;
  final User _authenticatedUser;

  void _onTextChanged(
    EditNoteTextChanged event,
    Emitter<EditNoteState> emit,
  ) {
    emit(state.copyWith(text: event.text));
  }

  Future<void> _onSubmitted(
    EditNoteSubmitted event,
    Emitter<EditNoteState> emit,
  ) async {
    emit(state.copyWith(status: EditNoteStatus.loading));
    final note = (state.initialNote ?? Note.empty()).copyWith(
      lastEdit: DateTime.now(),
      text: state.text,
      user: _authenticatedUser,
      comments: state.comments,
    );

    try {
      await _notesRepository.saveNote(note);
      emit(state.copyWith(status: EditNoteStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditNoteStatus.failure));
    }
  }
}
