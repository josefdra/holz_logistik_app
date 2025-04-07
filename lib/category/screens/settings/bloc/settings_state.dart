part of 'settings_bloc.dart';

enum SettingsStatus { initial, loading, success, failure }

final class SettingsState extends Equatable {
  SettingsState({
    this.status = SettingsStatus.initial,
    User? authenticatedUser,
  }) : authenticatedUser = authenticatedUser ?? User.empty();

  final SettingsStatus status;
  final User authenticatedUser;

  SettingsState copyWith({
    SettingsStatus? status,
    User? authenticatedUser,
  }) {
    return SettingsState(
      status: status ?? this.status,
      authenticatedUser: authenticatedUser ?? this.authenticatedUser,
    );
  }

  @override
  List<Object?> get props => [
        status,
        authenticatedUser,
      ];
}
