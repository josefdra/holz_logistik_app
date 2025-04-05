part of 'edit_user_bloc.dart';

enum EditUserStatus { initial, loading, success, failure }

extension EditUserStatusX on EditUserStatus {
  bool get isLoadingOrSuccess => [
        EditUserStatus.loading,
        EditUserStatus.success,
      ].contains(this);
}

final class EditUserState extends Equatable {
  const EditUserState({
    this.status = EditUserStatus.initial,
    this.initialUser,
    this.role = Role.basic,
    this.name = '',
  });

  final EditUserStatus status;
  final User? initialUser;
  final Role role;
  final String name;

  bool get isNewUser => initialUser == null;

  EditUserState copyWith({
    EditUserStatus? status,
    User? initialUser,
    Role? role,
    String? name,
  }) {
    return EditUserState(
      status: status ?? this.status,
      initialUser: initialUser ?? this.initialUser,
      role: role ?? this.role,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [status, initialUser, role, name];
}
