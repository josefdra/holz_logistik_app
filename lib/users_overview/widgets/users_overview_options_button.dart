import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/users_overview/users_overview.dart';

@visibleForTesting
enum UsersOverviewOption { toggleAll, clearCompleted }

class UsersOverviewOptionsButton extends StatelessWidget {
  const UsersOverviewOptionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final users = context.select((UsersOverviewBloc bloc) => bloc.state.users);
    final hasUsers = users.isNotEmpty;
    final completedUsersAmount = users.where((user) => user.isCompleted).length;

    return PopupMenuButton<UsersOverviewOption>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      tooltip: l10n.usersOverviewOptionsTooltip,
      onSelected: (options) {
        switch (options) {
          case UsersOverviewOption.toggleAll:
            context
                .read<UsersOverviewBloc>()
                .add(const UsersOverviewToggleAllRequested());
          case UsersOverviewOption.clearCompleted:
            context
                .read<UsersOverviewBloc>()
                .add(const UsersOverviewClearCompletedRequested());
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: UsersOverviewOption.toggleAll,
            enabled: hasUsers,
            child: Text(
              completedUsersAmount == users.length
                  ? l10n.usersOverviewOptionsMarkAllIncomplete
                  : l10n.usersOverviewOptionsMarkAllComplete,
            ),
          ),
          PopupMenuItem(
            value: UsersOverviewOption.clearCompleted,
            enabled: hasUsers && completedUsersAmount > 0,
            child: Text(l10n.usersOverviewOptionsClearCompleted),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}
