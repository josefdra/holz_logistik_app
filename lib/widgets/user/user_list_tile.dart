import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    required this.user,
    super.key,
    this.onDismissed,
    this.onTap,
  });

  final User user;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('todoListTile_dismissible_${user.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _showDeleteConfirmation(context),
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
        title: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          user.role.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          onPressed: () => _showDeleteConfirmation(context),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Benutzer löschen'),
          content: const Text('Diesen Benutzer sicher löschen?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onDismissed?.call(DismissDirection.endToStart);
                  },
                  child: const Text('Löschen'),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (result ?? false) {
      onDismissed?.call(DismissDirection.endToStart);
    }

    return result ?? false;
  }
}
