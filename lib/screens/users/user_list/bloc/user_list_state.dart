part of 'user_list_bloc.dart';

enum UserListStatus { initial, loading, success, failure }

final class UserListState extends Equatable {
  const UserListState({
    this.status = UserListStatus.initial,
    this.users = const [],
    this.filter = UserListFilter.all,
    this.lastDeletedUser,
  });

  final UserListStatus status;
  final List<User> users;
  final UserListFilter filter;
  final User? lastDeletedUser;

  Iterable<User> get filteredUsers => filter.applyAll(users);

  UserListState copyWith({
    UserListStatus? status,
    List<User>? users,
    UserListFilter? filter,
    User? lastDeletedUser,
  }) {
    return UserListState(
      status: status ?? this.status,
      users: users != null ? sortByDate(users) : this.users,
      filter: filter ?? this.filter,
      lastDeletedUser: lastDeletedUser ?? this.lastDeletedUser,
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
