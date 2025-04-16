import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/notes/notes.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({
    required NoteRepository noteRepository,
  })  : _noteRepository = noteRepository,
        super(NotesState()) {
    on<NotesSubscriptionRequested>(_onSubscriptionRequested);
    on<NotesNoteDeleted>(_onNoteDeleted);
    on<NotesUndoDeletionRequested>(_onUndoDeletionRequested);
  }

  final NoteRepository _noteRepository;

  Future<void> _onSubscriptionRequested(
    NotesSubscriptionRequested event,
    Emitter<NotesState> emit,
  ) async {
    emit(state.copyWith(status: NotesStatus.loading));

    await emit.forEach<List<Note>>(
      _noteRepository.notes,
      onData: (notes) => state.copyWith(
        status: NotesStatus.success,
        notes: notes,
      ),
      onError: (_, __) => state.copyWith(
        status: NotesStatus.failure,
      ),
    );
  }

  Future<void> _onNoteDeleted(
    NotesNoteDeleted event,
    Emitter<NotesState> emit,
  ) async {
    emit(state.copyWith(lastDeletedNote: event.note));
    await _noteRepository.deleteNote(event.note.id);
  }

  Future<void> _onUndoDeletionRequested(
    NotesUndoDeletionRequested event,
    Emitter<NotesState> emit,
  ) async {
    assert(
      state.lastDeletedNote != null,
      'Last deleted note can not be null.',
    );

    final note = state.lastDeletedNote!;
    emit(state.copyWith());
    await _noteRepository.saveNote(note);
  }

  @override
  Future<void> close() {
    state.scrollController.dispose();
    return super.close();
  }
}
