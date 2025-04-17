import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:holz_logistik/screens/users/edit_user/edit_user.dart';
import 'package:holz_logistik/screens/users/user_list/user_list.dart';
import 'package:holz_logistik/widgets/user/user_widgets.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => UserListBloc(
          userRepository: context.read<UserRepository>(),
        ),
        child: const UserListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (context) => UserListBloc(
        userRepository: context.read<UserRepository>(),
      )..add(const UserListSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.userListAppBarTitle),
          actions: const [
            UserListFilterButton(),
          ],
        ),
        body: const UserList(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'userListPageFloatingActionButton',
          shape: const CircleBorder(),
          onPressed: () => Navigator.of(context).push(EditUserPage.route()),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<UserListBloc, UserListState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == UserListStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.userListErrorSnackbarText),
                  ),
                );
            }
          },
        ),
        BlocListener<UserListBloc, UserListState>(
          listenWhen: (previous, current) =>
              previous.lastDeletedUser != current.lastDeletedUser &&
              current.lastDeletedUser != null,
          listener: (context, state) {
            final deletedUser = state.lastDeletedUser!;
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.userListUserDeletedSnackbarText(
                      deletedUser.name,
                    ),
                  ),
                  action: SnackBarAction(
                    label: l10n.userListUndoDeletionButtonText,
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      context
                          .read<UserListBloc>()
                          .add(const UserListUndoDeletionRequested());
                    },
                  ),
                ),
              );
          },
        ),
      ],
      child: BlocBuilder<UserListBloc, UserListState>(
        builder: (context, state) {
          if (state.users.isEmpty) {
            if (state.status == UserListStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status != UserListStatus.success) {
              return const SizedBox();
            } else {
              return Center(
                child: Text(
                  l10n.userListEmptyText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
          }

          return Scrollbar(
            controller: context.read<UserListBloc>().scrollController,
            child: ListView.builder(
              controller: context.read<UserListBloc>().scrollController,
              itemCount: state.filteredUsers.length,
              itemBuilder: (_, index) {
                final user = state.filteredUsers.elementAt(index);
                return UserListTile(
                  user: user,
                  onDismissed: (_) {
                    context.read<UserListBloc>().add(UserListUserDeleted(user));
                  },
                  onTap: () {
                    Navigator.of(context).push(
                      EditUserPage.route(initialUser: user),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
