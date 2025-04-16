part of 'user_list_bloc.dart';

enum UserListStatus { initial, loading, success, failure }

final class UserListState extends Equatable {
  UserListState({
    this.status = UserListStatus.initial,
    this.users = const [],
    this.filter = UserListFilter.all,
    this.lastDeletedUser,
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController();

  final UserListStatus status;
  final List<User> users;
  final UserListFilter filter;
  final User? lastDeletedUser;
  final ScrollController scrollController;

  Iterable<User> get filteredUsers => filter.applyAll(users);

  UserListState copyWith({
    UserListStatus? status,
    List<User>? users,
    UserListFilter? filter,
    User? lastDeletedUser,
  }) {
    return UserListState(
      status: status ?? this.status,
      users: users != null ? sortByLastEdit(users) : this.users,
      filter: filter ?? this.filter,
      lastDeletedUser: lastDeletedUser ?? this.lastDeletedUser,
      scrollController: scrollController,
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
