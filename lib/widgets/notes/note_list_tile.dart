import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return StreamBuilder<User>(
      stream: context.read<AuthenticationRepository>().authenticatedUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        final user = snapshot.data!;
        final canModify =
            user.id == note.userId || user.role.isPrivileged == true;

        return Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            onTap: canModify ? onTap : null,
            title: Text(note.text),
            trailing: canModify
                ? IconButton(
                    onPressed: () => onDelete?.call(),
                    icon: const Icon(Icons.delete_outline),
                  )
                : null,
          ),
        );
      },
    );
  }
}
