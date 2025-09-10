part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

final class SettingsApiKeyChanged extends SettingsEvent {
  const SettingsApiKeyChanged(this.apiKey);

  final String apiKey;

  @override
  List<Object> get props => [apiKey];
}

final class SettingsSubscriptionRequested extends SettingsEvent {
  const SettingsSubscriptionRequested();
}

final class SettingsAuthenticationVerificationRequested extends SettingsEvent {
  const SettingsAuthenticationVerificationRequested();
}

final class SettingsDatabaseChanged extends SettingsEvent {
  const SettingsDatabaseChanged(this.database);

  final String database;

  @override
  List<Object> get props => [database];
}
