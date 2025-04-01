part of 'users_overview_bloc.dart';

enum UsersOverviewStatus { initial, loading, success, failure }

final class UsersOverviewState extends Equatable {
  const UsersOverviewState({
    this.status = UsersOverviewStatus.initial,
    this.users = const [],
    this.filter = UsersViewFilter.all,
    this.lastDeletedUser,
  });

  final UsersOverviewStatus status;
  final List<User> users;
  final UsersViewFilter filter;
  final User? lastDeletedUser;

  Iterable<User> get filteredUsers => filter.applyAll(users);

  UsersOverviewState copyWith({
    UsersOverviewStatus Function()? status,
    List<User> Function()? users,
    UsersViewFilter Function()? filter,
    User? Function()? lastDeletedUser,
  }) {
    return UsersOverviewState(
      status: status != null ? status() : this.status,
      users: users != null ? users() : this.users,
      filter: filter != null ? filter() : this.filter,
      lastDeletedUser:
          lastDeletedUser != null ? lastDeletedUser() : this.lastDeletedUser,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users,
        filter,
        lastDeletedUser,
      ];
}
