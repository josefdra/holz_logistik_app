import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/notes_list/notes_list.dart';
import 'package:holz_logistik/widgets/notes/note_widgets.dart';
import 'package:holz_logistik_backend/repository/note_repository.dart';

class NotesListPage extends StatelessWidget {
  const NotesListPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => NotesListBloc(
          noteRepository: context.read<NoteRepository>(),
        ),
        child: const NotesListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesListBloc(
        noteRepository: context.read<NoteRepository>(),
      )..add(const NotesListSubscriptionRequested()),
      child: Scaffold(
        body: const NoteList(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'notesPageFloatingActionButton',
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          onPressed: () => showDialog<EditNoteWidget>(
            context: context,
            builder: (context) => const EditNoteWidget(),
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
    return MultiBlocListener(
      listeners: [
        BlocListener<NotesListBloc, NotesListState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == NotesListStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Fehler beim Laden der Notizen'),
                  ),
                );
            }
          },
        ),
        BlocListener<NotesListBloc, NotesListState>(
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
                  content: const Text(
                    'Notiz gelöscht',
                  ),
                  action: SnackBarAction(
                    label: 'Rückgängig',
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      context
                          .read<NotesListBloc>()
                          .add(const NotesListUndoDeletionRequested());
                    },
                  ),
                ),
              );
          },
        ),
      ],
      child: BlocBuilder<NotesListBloc, NotesListState>(
        builder: (context, state) {
          if (state.notes.isEmpty) {
            if (state.status == NotesListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status != NotesListStatus.success) {
              return const SizedBox();
            } else {
              return Center(
                child: Text(
                  'Keine Notizen',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
          }

          return Scrollbar(
            controller: context.read<NotesListBloc>().scrollController,
            child: ListView.builder(
              controller: context.read<NotesListBloc>().scrollController,
              itemCount: state.notes.length,
              itemBuilder: (_, index) {
                final note = state.notes.elementAt(index);
                return NoteListTile(
                  note: note,
                  onDelete: () {
                    context.read<NotesListBloc>().add(
                          NotesListNoteDeleted(note),
                        );
                  },
                  onTap: () => showDialog<EditNoteWidget>(
                    context: context,
                    builder: (context) => EditNoteWidget(note: note),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
