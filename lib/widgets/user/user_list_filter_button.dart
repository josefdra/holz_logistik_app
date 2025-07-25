import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/users/users.dart';
import 'package:holz_logistik/screens/users/user_list/user_list.dart';

class UserListFilterButton extends StatelessWidget {
  const UserListFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
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
          const PopupMenuItem(
            value: UserListFilter.all,
            child: Text('Alle'),
          ),
          const PopupMenuItem(
            value: UserListFilter.basicOnly,
            child: Text('Nur Basisnutzer'),
          ),
          const PopupMenuItem(
            value: UserListFilter.privilegedOnly,
            child: Text('Nur privilegierte Nutzer'),
          ),
          const PopupMenuItem(
            value: UserListFilter.adminOnly,
            child: Text('Nur Admins'),
          ),
          const PopupMenuItem(
            value: UserListFilter.elevatedAccess,
            child: Text('Nutzer mit erhöhten Rechten'),
          ),
        ];
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}
