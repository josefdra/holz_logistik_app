import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/authentication_repository.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(SettingsState()) {
    on<SettingsSubscriptionRequested>(_onSubscriptionRequested);
    on<SettingsApiKeyChanged>(_onApiKeyChanged);
    on<SettingsAuthenticationVerificationRequested>(_onVerificationRequested);
  }

  final AuthenticationRepository _authenticationRepository;

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

  void _onVerificationRequested(
    SettingsAuthenticationVerificationRequested event,
    Emitter<SettingsState> emit,
  ) {
    _authenticationRepository.updateApiKey(state.apiKey);
  }
}
