import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../lib/l10n/l10n.dart';
import '../../../notes.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class EditNoteWidget extends StatelessWidget {
  const EditNoteWidget({
    super.key,
  });

  static Route<void> route({Note? initialNote}) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => EditNoteBloc(
          authenticatedUser:
              context.read<AuthenticationRepository>().currentUser,
          notesRepository: context.read<NoteRepository>(),
          initialNote: initialNote,
        ),
        child: const EditNoteWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditNoteBloc, EditNoteState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditNoteStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const EditNoteView(),
    );
  }
}

class EditNoteView extends StatelessWidget {
  const EditNoteView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = context.select((EditNoteBloc bloc) => bloc.state.status);
    final isNewNote = context.select(
      (EditNoteBloc bloc) => bloc.state.isNewNote,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewNote
              ? l10n.editNoteAddAppBarTitle
              : l10n.editNoteEditAppBarTitle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'editNoteWidgetFloatingActionButton',
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed: status.isLoadingOrSuccess
            ? null
            : () => context.read<EditNoteBloc>().add(const EditNoteSubmitted()),
        child: status.isLoadingOrSuccess
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
      body: const CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _TextField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditNoteBloc>().state;
    final hintText = state.initialNote?.text ?? '';
    final error = state.validationErrors['text'];

    return TextFormField(
      key: const Key('editNoteView_text_textFormField'),
      initialValue: state.text,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editNoteTextLabel,
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
