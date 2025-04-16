import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

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
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(state.copyWith(validationErrors: updatedErrors, text: event.text));
  }

  Map<String, String?> _validateFields() {
    final errors = <String, String?>{};

    if (state.text == '') {
      errors['text'] = 'Text darf nicht leer sein';
    }

    return errors;
  }

  Future<void> _onSubmitted(
    EditNoteSubmitted event,
    Emitter<EditNoteState> emit,
  ) async {
    final validationErrors = _validateFields();

    if (validationErrors.isNotEmpty) {
      emit(
        state.copyWith(
          validationErrors: validationErrors,
          status: EditNoteStatus.invalid,
        ),
      );
      return;
    }

    emit(state.copyWith(status: EditNoteStatus.loading));

    final note = (state.initialNote ?? Note.empty()).copyWith(
      lastEdit: DateTime.now(),
      text: state.text,
      userId: _authenticatedUser.id,
    );

    try {
      await _notesRepository.saveNote(note);
      emit(state.copyWith(status: EditNoteStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditNoteStatus.failure));
    }
  }
}
