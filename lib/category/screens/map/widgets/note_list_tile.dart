import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/note_repository.dart';

class NoteListTile extends StatelessWidget {
  const NoteListTile({
    required this.note,
    super.key,
    this.onDismissed,
    this.onTap,
  });

  final Note note;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('noteListTile_dismissible_${note.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Color(0xAAFFFFFF),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(note.text),
        trailing: IconButton(
          onPressed: () => onDismissed?.call(DismissDirection.endToStart),
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
