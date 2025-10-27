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
  })  : _authenticationRepository = authenticationRepository,
        _coreSyncService = coreSyncService,
        super(const MainState()) {
    on<MainSubscriptionRequested>(_onSubscriptionRequested);
    on<MainApiKeyChanged>(_onApiKeyChanged);
    on<MainTabChanged>(_onTabChanged);
    on<MainConnectionChanged>(_onConnectionChanged);
    on<MainConnectivityChanged>(_onConnectivityChanged);
    on<MainConnectPressed>(_onConnectPressed);
  }

  final AuthenticationRepository _authenticationRepository;
  final CoreSyncService _coreSyncService;

  late final StreamSubscription<ConnectionStatus>?
      _connectionUpdatesSubscription;
  late final StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  Future<void> _connect() async {
    final apiKey = await _authenticationRepository.apiKey;
    await _coreSyncService.connect(apiKey: apiKey);
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

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
          (connectivity) =>
              add(MainConnectivityChanged(connectivity: connectivity)),
        );

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
    await _connect();
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
  }

  Future<void> _onConnectivityChanged(
    MainConnectivityChanged event,
    Emitter<MainState> emit,
  ) async {
    final result = event.connectivity[0];
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet) {
      await _connect();
    } else {
      emit(state.copyWith(connectionStatus: ConnectionStatus.disconnected));
    }
  }

  Future<void> _onConnectPressed(
    MainConnectPressed event,
    Emitter<MainState> emit,
  ) async {
    await _connect();
  }

  @override
  Future<void> close() async {
    await _connectionUpdatesSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}
