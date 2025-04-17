part of 'edit_user_bloc.dart';

sealed class EditUserEvent extends Equatable {
  const EditUserEvent();

  @override
  List<Object> get props => [];
}

final class EditUserRoleChanged extends EditUserEvent {
  const EditUserRoleChanged(this.role);

  final Role role;

  @override
  List<Object> get props => [role];
}

final class EditUserNameChanged extends EditUserEvent {
  const EditUserNameChanged(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

final class EditUserSubmitted extends EditUserEvent {
  const EditUserSubmitted();
}
