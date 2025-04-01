import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:holz_logistik/users_overview/users_overview.dart';

class UsersOverviewFilterButton extends StatelessWidget {
  const UsersOverviewFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final activeFilter =
        context.select((UsersOverviewBloc bloc) => bloc.state.filter);

    return PopupMenuButton<UsersViewFilter>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      initialValue: activeFilter,
      tooltip: l10n.usersOverviewFilterTooltip,
      onSelected: (filter) {
        context
            .read<UsersOverviewBloc>()
            .add(UsersOverviewFilterChanged(filter));
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: UsersViewFilter.all,
            child: Text(l10n.usersOverviewFilterAll),
          ),
          PopupMenuItem(
            value: UsersViewFilter.activeOnly,
            child: Text(l10n.usersOverviewFilterActiveOnly),
          ),
          PopupMenuItem(
            value: UsersViewFilter.completedOnly,
            child: Text(l10n.usersOverviewFilterCompletedOnly),
          ),
        ];
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}
