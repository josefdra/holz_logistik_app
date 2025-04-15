import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/notes/notes.dart';
import 'package:holz_logistik_backend/repository/note_repository.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  static Route<void> route({Note? initialNote}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => NotesBloc(
          noteRepository: context.read<NoteRepository>(),
        ),
        child: const NotesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc(
        noteRepository: context.read<NoteRepository>(),
      )..add(const NotesSubscriptionRequested()),
      child: Scaffold(
        body: const NoteList(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'notesPageFloatingActionButton',
          shape: const CircleBorder(),
          onPressed: () => Navigator.of(context).push(
            EditNoteWidget.route(),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<NotesBloc, NotesState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == NotesStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.noteListErrorSnackbarText),
                  ),
                );
            }
          },
        ),
        BlocListener<NotesBloc, NotesState>(
          listenWhen: (previous, current) =>
              previous.lastDeletedNote != current.lastDeletedNote &&
              current.lastDeletedNote != null,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 5),
                  content: Text(
                    l10n.noteListNoteDeletedSnackbarText,
                  ),
                  action: SnackBarAction(
                    label: l10n.noteListUndoDeletionButtonText,
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      context
                          .read<NotesBloc>()
                          .add(const NotesUndoDeletionRequested());
                    },
                  ),
                ),
              );
          },
        ),
      ],
      child: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state.notes.isEmpty) {
            if (state.status == NotesStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state.status != NotesStatus.success) {
              return const SizedBox();
            } else {
              return Center(
                child: Text(
                  l10n.noteListEmptyText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
          }

          return CupertinoScrollbar(
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: state.notes.length,
              itemBuilder: (_, index) {
                final note = state.notes.elementAt(index);
                return NoteListTile(
                  note: note,
                  onDelete: () {
                    context.read<NotesBloc>().add(
                          NotesNoteDeleted(note),
                        );
                  },
                  onTap: () {
                    Navigator.of(context).push(
                      EditNoteWidget.route(initialNote: note),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
