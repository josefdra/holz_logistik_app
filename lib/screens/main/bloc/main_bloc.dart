import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:holz_logistik_backend/sync/core_sync_service.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc({
    required AuthenticationRepository authenticationRepository,
    required CoreSyncService coreSyncService,
    required UserRepository userRepository,
  })  : _authenticationRepository = authenticationRepository,
        _coreSyncService = coreSyncService,
        _userRepository = userRepository,
        super(const MainState()) {
    on<MainSubscriptionRequested>(_onSubscriptionRequested);
    on<MainApiKeyChanged>(_onApiKeyChanged);
    on<MainTabChanged>(_onTabChanged);
    on<MainConnectionChanged>(_onConnectionChanged);
    on<MainConnectivityChanged>(_onConnectivityChanged);
  }

  final AuthenticationRepository _authenticationRepository;
  final CoreSyncService _coreSyncService;
  final UserRepository _userRepository;

  late final StreamSubscription<ConnectionStatus>?
      _connectionUpdatesSubscription;
  late final StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  void _attemptReconnect() {
    _authenticationRepository.connect();
    _userRepository.saveFutureUser(_authenticationRepository.currentUser);
  }

  Future<void> _authenticate() async {
    add(
      const MainConnectionChanged(
        ConnectionStatus.disconnected,
      ),
    );
  }

  Future<void> _onSubscriptionRequested(
    MainSubscriptionRequested event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(status: MainStatus.loading));

    _connectionUpdatesSubscription =
        _coreSyncService.connectionStatus.listen((status) {
      add(MainConnectionChanged(status));
    });

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.skip(1).listen(
              (connectivity) =>
                  add(MainConnectivityChanged(connectivity: connectivity)),
            );

    add(const MainApiKeyChanged());

    await emit.forEach<User>(
      _authenticationRepository.authenticatedUser,
      onData: (user) {
        return state.copyWith(
          status: MainStatus.success,
          isPrivileged: user.role.isPrivileged,
        );
      },
      onError: (_, __) => state.copyWith(
        status: MainStatus.error,
      ),
    );
  }

  Future<void> _onApiKeyChanged(
    MainApiKeyChanged event,
    Emitter<MainState> emit,
  ) async {
    await _authenticate();
  }

  Future<void> _onTabChanged(
    MainTabChanged event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(selectedTab: event.tab));
  }

  Future<void> _onConnectionChanged(
    MainConnectionChanged event,
    Emitter<MainState> emit,
  ) async {
    emit(state.copyWith(connectionStatus: event.connectionStatus));

    if (event.connectionStatus == ConnectionStatus.connected) {
      await _coreSyncService.sync();
    } else if ((event.connectionStatus == ConnectionStatus.disconnected ||
            event.connectionStatus == ConnectionStatus.error) &&
        !state.isReconnecting) {
      emit(state.copyWith(isReconnecting: true));

      _attemptReconnect();

      emit(state.copyWith(isReconnecting: false));
    }
  }

  Future<void> _onConnectivityChanged(
    MainConnectivityChanged event,
    Emitter<MainState> emit,
  ) async {
    final result = event.connectivity[0];
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet) {
      await _authenticationRepository.connect();
      await _userRepository
          .saveFutureUser(_authenticationRepository.currentUser);
    }
  }

  @override
  Future<void> close() async {
    await _connectionUpdatesSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}
