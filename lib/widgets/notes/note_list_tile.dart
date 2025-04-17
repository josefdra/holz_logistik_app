import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/note_repository.dart';

class NoteListTile extends StatelessWidget {
  const NoteListTile({
    required this.note,
    super.key,
    this.onDelete,
    this.onTap,
  });

  final Note note;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        onTap: onTap,
        title: Text(note.text),
        trailing: IconButton(
          onPressed: () => onDelete?.call(),
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
