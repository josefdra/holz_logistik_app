import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

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
          onPressed: () => _showDeleteConfirmation(context),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notiz löschen'),
          content: const Text('Diese Notiz sicher löschen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }
}
