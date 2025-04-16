part of 'user_list_bloc.dart';

sealed class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object> get props => [];
}

final class UserListSubscriptionRequested extends UserListEvent {
  const UserListSubscriptionRequested();
}

final class UserListUserDeleted extends UserListEvent {
  const UserListUserDeleted(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

final class UserListUndoDeletionRequested extends UserListEvent {
  const UserListUndoDeletionRequested();
}

class UserListFilterChanged extends UserListEvent {
  const UserListFilterChanged(this.filter);

  final UserListFilter filter;

  @override
  List<Object> get props => [filter];
}
