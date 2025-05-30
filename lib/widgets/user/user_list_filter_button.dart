import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:holz_logistik/models/users/users.dart';
import 'package:holz_logistik/screens/users/user_list/user_list.dart';

class UserListFilterButton extends StatelessWidget {
  const UserListFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final activeFilter =
        context.select((UserListBloc bloc) => bloc.state.filter);

    return PopupMenuButton<UserListFilter>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      initialValue: activeFilter,
      onSelected: (filter) {
        context
            .read<UserListBloc>()
            .add(UserListFilterChanged(filter));
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: UserListFilter.all,
            child: Text(l10n.userListFilterAll),
          ),
          PopupMenuItem(
            value: UserListFilter.basicOnly,
            child: Text(l10n.userListFilterBasicOnly),
          ),
          PopupMenuItem(
            value: UserListFilter.privilegedOnly,
            child: Text(l10n.userListFilterPrivilegedOnly),
          ),
          PopupMenuItem(
            value: UserListFilter.adminOnly,
            child: Text(l10n.userListFilterAdminOnly),
          ),
          PopupMenuItem(
            value: UserListFilter.elevatedAccess,
            child: Text(l10n.userListFilterElevatedAccess),
          ),
        ];
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}
