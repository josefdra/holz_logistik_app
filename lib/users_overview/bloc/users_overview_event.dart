part of 'users_overview_bloc.dart';

sealed class UsersOverviewEvent extends Equatable {
  const UsersOverviewEvent();

  @override
  List<Object> get props => [];
}

final class UsersOverviewSubscriptionRequested extends UsersOverviewEvent {
  const UsersOverviewSubscriptionRequested();
}

final class UsersOverviewUserCompletionToggled extends UsersOverviewEvent {
  const UsersOverviewUserCompletionToggled({
    required this.user,
    required this.role,
  });

  final User user;
  final bool role;

  @override
  List<Object> get props => [user, role];
}

final class UsersOverviewUserDeleted extends UsersOverviewEvent {
  const UsersOverviewUserDeleted(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

final class UsersOverviewUndoDeletionRequested extends UsersOverviewEvent {
  const UsersOverviewUndoDeletionRequested();
}

class UsersOverviewFilterChanged extends UsersOverviewEvent {
  const UsersOverviewFilterChanged(this.filter);

  final UsersViewFilter filter;

  @override
  List<Object> get props => [filter];
}
