import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'edit_note_event.dart';
part 'edit_note_state.dart';

class EditNoteBloc extends Bloc<EditNoteEvent, EditNoteState> {
  EditNoteBloc({
    required NoteRepository notesRepository,
    required AuthenticationRepository authenticationRepository,
    required Note? initialNote,
  })  : _notesRepository = notesRepository,
        _authenticationRepository = authenticationRepository,
        super(
          EditNoteState(
            initialNote: initialNote,
            text: initialNote?.text ?? '',
          ),
        ) {
    on<EditNoteSubscriptionRequested>(_onSubscriptionRequested);
    on<EditNoteTextChanged>(_onTextChanged);
    on<EditNoteUserUpdate>(_onUserUpdate);
    on<EditNoteSubmitted>(_onSubmitted);
  }

  final NoteRepository _notesRepository;
  final AuthenticationRepository _authenticationRepository;

  late final StreamSubscription<User>? _authenticationSubscription;

  void _onSubscriptionRequested(
    EditNoteSubscriptionRequested event,
    Emitter<EditNoteState> emit,
  ) {
    emit(state.copyWith(status: EditNoteStatus.loading));

    try {
      _authenticationSubscription =
          _authenticationRepository.authenticatedUser.listen(
        (user) => add(EditNoteUserUpdate(user)),
      );

      emit(state.copyWith(status: EditNoteStatus.ready));
    } catch (e) {
      emit(state.copyWith(status: EditNoteStatus.failure));
    }
  }

  void _onTextChanged(
    EditNoteTextChanged event,
    Emitter<EditNoteState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(state.copyWith(validationErrors: updatedErrors, text: event.text));
  }

  void _onUserUpdate(
    EditNoteUserUpdate event,
    Emitter<EditNoteState> emit,
  ) {
    emit(state.copyWith(user: event.user));
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

    final note = (state.initialNote ?? Note()).copyWith(
      lastEdit: DateTime.now(),
      text: state.text,
      userId: state.user.id,
    );

    try {
      await _notesRepository.saveNote(note);
      emit(state.copyWith(status: EditNoteStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditNoteStatus.failure));
    }
  }

  @override
  Future<void> close() {
    _authenticationSubscription?.cancel();
    return super.close();
  }
}
