import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/widgets/notes/edit_note/edit_note.dart';
import 'package:holz_logistik_backend/repository/authentication_repository.dart';
import 'package:holz_logistik_backend/repository/note_repository.dart';

class EditNoteWidget extends StatelessWidget {
  const EditNoteWidget({
    super.key,
    this.note,
  });

  final Note? note;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditNoteBloc(
        authenticationRepository: context.read<AuthenticationRepository>(),
        notesRepository: context.read<NoteRepository>(),
        initialNote: note,
      )..add(const EditNoteSubscriptionRequested()),
      child: BlocListener<EditNoteBloc, EditNoteState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            (current.status == EditNoteStatus.success),
        listener: (context, state) {
          Navigator.of(context).pop();
        },
        child: const EditNoteView(),
      ),
    );
  }
}

class EditNoteView extends StatelessWidget {
  const EditNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditNoteBloc, EditNoteState>(
      builder: (context, state) {
        if (state.status == EditNoteStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 70),
          child: SizedBox(
            width: 600,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _TextField(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filled(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                        IconButton.filled(
                          onPressed: () {
                            context
                                .read<EditNoteBloc>()
                                .add(const EditNoteSubmitted());
                          },
                          icon: const Icon(Icons.check),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditNoteBloc>().state;
    final hintText = state.initialNote?.text ?? '';
    final error = state.validationErrors['text'];

    return TextFormField(
      key: const Key('editNoteView_text_textFormField'),
      initialValue: state.text,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: 'Notiz',
        hintText: hintText,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
      maxLength: 300,
      maxLines: 7,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        context.read<EditNoteBloc>().add(EditNoteTextChanged(value));
      },
    );
  }
}
