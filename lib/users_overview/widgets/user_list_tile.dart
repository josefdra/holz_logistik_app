import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/api/user_api.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    required this.user,
    super.key,
    this.onTogglePrivileged,
    this.onDismissed,
    this.onTap,
  });

  final User user;
  final ValueChanged<bool>? onTogglePrivileged;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.bodySmall?.color;

    return Dismissible(
      key: Key('userListTile_dismissible_${user.id}'),
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
        title: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: user.role == Role.basic
              ? null
              : TextStyle(
                  color: captionColor,
                  decoration: TextDecoration.lineThrough,
                ),
        ),
        leading: Checkbox(
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          value: user.role == Role.privileged,
          onChanged: onTogglePrivileged == null
              ? null
              : (value) => onTogglePrivileged!(value!),
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
