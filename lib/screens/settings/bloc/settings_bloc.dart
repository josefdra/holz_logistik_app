import 'dart:async';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/authentication_repository.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required AuthenticationRepository authenticationRepository,
    VoidCallback? onApiKeyChanged,
  })  : _authenticationRepository = authenticationRepository,
        _connectionRequest = onApiKeyChanged,
        super(SettingsState()) {
    on<SettingsSubscriptionRequested>(_onSubscriptionRequested);
    on<SettingsApiKeyChanged>(_onApiKeyChanged);
    on<SettingsAuthenticationVerificationRequested>(_onVerificationRequested);
    on<SettingsDatabaseChanged>(_onDatabaseChanged);
  }

  final AuthenticationRepository _authenticationRepository;
  final VoidCallback? _connectionRequest;

  Future<void> _onSubscriptionRequested(
    SettingsSubscriptionRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    await emit.forEach<User>(
      _authenticationRepository.authenticatedUser,
      onData: (authenticatedUser) => state.copyWith(
        status: SettingsStatus.success,
        authenticatedUser: authenticatedUser,
      ),
      onError: (_, __) => state.copyWith(
        status: SettingsStatus.failure,
      ),
    );
  }

  void _onApiKeyChanged(
    SettingsApiKeyChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(apiKey: event.apiKey));
  }

  Future<void> _onVerificationRequested(
    SettingsAuthenticationVerificationRequested event,
    Emitter<SettingsState> emit,
  ) async {
    await _authenticationRepository.setNoActiveDb();
    await _authenticationRepository.setActiveApiKey(state.apiKey);

    if (_connectionRequest != null) {
      _connectionRequest();
    }
  }

  Future<void> _onDatabaseChanged(
    SettingsDatabaseChanged event,
    Emitter<SettingsState> emit,
  ) async {
    await _authenticationRepository.setActiveDb(event.database);

    if (_connectionRequest != null) {
      _connectionRequest();
    }
  }
}
