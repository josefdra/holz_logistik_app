part of 'settings_bloc.dart';

enum SettingsStatus { initial, loading, success, failure }

extension SettingsStatusX on SettingsStatus {
  bool get isLoadingOrSuccess => [
        SettingsStatus.loading,
        SettingsStatus.success,
      ].contains(this);
}

final class SettingsState extends Equatable {
  SettingsState({
    this.status = SettingsStatus.initial,
    User? authenticatedUser,
    this.apiKey = '',
  }) : authenticatedUser = authenticatedUser ?? User();

  final SettingsStatus status;
  final User authenticatedUser;
  final String apiKey;

  SettingsState copyWith({
    SettingsStatus? status,
    User? authenticatedUser,
    String? apiKey,
  }) {
    return SettingsState(
      status: status ?? this.status,
      authenticatedUser: authenticatedUser ?? this.authenticatedUser,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  List<Object?> get props => [
        status,
        authenticatedUser,
        apiKey,
      ];
}
