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
    this.title = '',
    this.description = '',
  });

  final EditUserStatus status;
  final User? initialUser;
  final String title;
  final String description;

  bool get isNewUser => initialUser == null;

  EditUserState copyWith({
    EditUserStatus? status,
    User? initialUser,
    String? title,
    String? description,
  }) {
    return EditUserState(
      status: status ?? this.status,
      initialUser: initialUser ?? this.initialUser,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [status, initialUser, title, description];
}
