import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/general/sort.dart';
import 'package:holz_logistik_backend/repository/note_repository.dart';

part 'notes_list_event.dart';
part 'notes_list_state.dart';

class NotesListBloc extends Bloc<NotesListEvent, NotesListState> {
  NotesListBloc({
    required NoteRepository noteRepository,
  })  : _noteRepository = noteRepository,
        super(const NotesListState()) {
    on<NotesListSubscriptionRequested>(_onSubscriptionRequested);
    on<NotesListNoteDeleted>(_onNoteDeleted);
    on<NotesListUndoDeletionRequested>(_onUndoDeletionRequested);
  }

  final NoteRepository _noteRepository;
  final scrollController = ScrollController();

  Future<void> _onSubscriptionRequested(
    NotesListSubscriptionRequested event,
    Emitter<NotesListState> emit,
  ) async {
    emit(state.copyWith(status: NotesListStatus.loading));

    await emit.forEach<List<Note>>(
      _noteRepository.notes,
      onData: (notes) => state.copyWith(
        status: NotesListStatus.success,
        notes: notes,
      ),
      onError: (_, __) => state.copyWith(
        status: NotesListStatus.failure,
      ),
    );
  }

  Future<void> _onNoteDeleted(
    NotesListNoteDeleted event,
    Emitter<NotesListState> emit,
  ) async {
    emit(state.copyWith(lastDeletedNote: event.note));
    await _noteRepository.deleteNote(event.note.id);
  }

  Future<void> _onUndoDeletionRequested(
    NotesListUndoDeletionRequested event,
    Emitter<NotesListState> emit,
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
    scrollController.dispose();
    return super.close();
  }
}
