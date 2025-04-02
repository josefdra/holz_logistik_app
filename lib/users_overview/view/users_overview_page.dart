import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/edit_user/view/edit_user_page.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:holz_logistik/users_overview/users_overview.dart';
import 'package:user_repository/user_repository.dart';

class UsersOverviewPage extends StatelessWidget {
  const UsersOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersOverviewBloc(
        userRepository: context.read<UserRepository>(),
      )..add(const UsersOverviewSubscriptionRequested()),
      child: const UsersOverviewView(),
    );
  }
}

class UsersOverviewView extends StatelessWidget {
  const UsersOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.usersOverviewAppBarTitle),
        actions: const [
          UsersOverviewFilterButton(),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<UsersOverviewBloc, UsersOverviewState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == UsersOverviewStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.usersOverviewErrorSnackbarText),
                    ),
                  );
              }
            },
          ),
          BlocListener<UsersOverviewBloc, UsersOverviewState>(
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
                      l10n.usersOverviewUserDeletedSnackbarText(
                        deletedUser.name,
                      ),
                    ),
                    action: SnackBarAction(
                      label: l10n.usersOverviewUndoDeletionButtonText,
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context
                            .read<UsersOverviewBloc>()
                            .add(const UsersOverviewUndoDeletionRequested());
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<UsersOverviewBloc, UsersOverviewState>(
          builder: (context, state) {
            if (state.users.isEmpty) {
              if (state.status == UsersOverviewStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != UsersOverviewStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    l10n.usersOverviewEmptyText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }

            return CupertinoScrollbar(
              child: ListView.builder(
                itemCount: state.filteredUsers.length,
                itemBuilder: (_, index) {
                  final user = state.filteredUsers.elementAt(index);
                  return UserListTile(
                    user: user,
                    onTogglePrivileged: (isPrivileged) {
                      context.read<UsersOverviewBloc>().add(
                            UsersOverviewUserCompletionToggled(
                              user: user,
                              isPrivileged: isPrivileged,
                            ),
                          );
                    },
                    onDismissed: (_) {
                      context
                          .read<UsersOverviewBloc>()
                          .add(UsersOverviewUserDeleted(user));
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
      ),
    );
  }
}
