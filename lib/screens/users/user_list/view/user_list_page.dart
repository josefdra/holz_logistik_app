import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocProvider(
      create: (context) => UserListBloc(
        userRepository: context.read<UserRepository>(),
      )..add(const UserListSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutzer'),
          actions: const [
            UserListFilterButton(),
          ],
        ),
        body: const UserList(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: 'userListPageFloatingActionButton',
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
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
    return BlocListener<UserListBloc, UserListState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == UserListStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Ein Fehler ist während dem Laden der Nutzer aufgetreten',
                ),
              ),
            );
        }
      },
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
                  'Keine Nutzer gefunden',
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
