import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'finished_contracts_event.dart';
part 'finished_contracts_state.dart';

class FinishedContractsBloc
    extends Bloc<FinishedContractsEvent, FinishedContractsState> {
  FinishedContractsBloc({
    required ContractRepository contractRepository,
  })  : _contractRepository = contractRepository,
        super(FinishedContractsState()) {
    on<FinishedContractsSubscriptionRequested>(_onSubscriptionRequested);
    on<FinishedContractsContractUpdate>(_onContractUpdate);
    on<FinishedContractsRefreshRequested>(_onRefreshRequested);
    on<FinishedContractsDateChanged>(_onDateChanged);
    on<FinishedContractsAutomaticDate>(_onAutomaticDate);

    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDateChange();
    });
  }

  final ContractRepository _contractRepository;
  late final Timer _dateCheckTimer;
  final scrollController = ScrollController();

  late final StreamSubscription<Map<String, dynamic>>?
      _finishedContractUpdateSubscription;

  void _checkDateChange() {
    final now = DateTime.now();

    if (now.isAfter(state.endDate) && !state.customDate) {
      add(const FinishedContractsRefreshRequested());
    }
  }

  Future<void> _onSubscriptionRequested(
    FinishedContractsSubscriptionRequested event,
    Emitter<FinishedContractsState> emit,
  ) async {
    emit(state.copyWith(status: FinishedContractsStatus.loading));
    add(const FinishedContractsContractUpdate());

    _finishedContractUpdateSubscription =
        _contractRepository.finishedContractUpdates.listen((contractUpdate) {
      if (contractUpdate.isNotEmpty &&
          state.startDate.millisecondsSinceEpoch <=
              (contractUpdate['lastEdit'] as DateTime).millisecondsSinceEpoch &&
          (contractUpdate['lastEdit'] as DateTime).millisecondsSinceEpoch <=
              state.endDate.millisecondsSinceEpoch) {
        add(const FinishedContractsContractUpdate());
      }
    });
  }

  Future<void> _onContractUpdate(
    FinishedContractsContractUpdate event,
    Emitter<FinishedContractsState> emit,
  ) async {
    final contracts = await _contractRepository.getFinishedContractsByDate(
      state.startDate,
      state.endDate,
    );

    emit(
      state.copyWith(
        status: FinishedContractsStatus.success,
        contracts: contracts,
      ),
    );
  }

  Future<void> _onRefreshRequested(
    FinishedContractsRefreshRequested event,
    Emitter<FinishedContractsState> emit,
  ) async {
    final endDate = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
    final startDate = endDate.subtract(const Duration(days: 32));

    emit(
      state.copyWith(
        startDate: startDate,
        endDate: endDate,
      ),
    );

    add(const FinishedContractsContractUpdate());
  }

  Future<void> _onDateChanged(
    FinishedContractsDateChanged event,
    Emitter<FinishedContractsState> emit,
  ) async {
    emit(
      state.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
        customDate: true,
      ),
    );

    add(const FinishedContractsContractUpdate());
  }

  Future<void> _onAutomaticDate(
    FinishedContractsAutomaticDate event,
    Emitter<FinishedContractsState> emit,
  ) async {
    emit(state.copyWith(customDate: false));

    add(const FinishedContractsRefreshRequested());
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    _finishedContractUpdateSubscription?.cancel();
    _dateCheckTimer.cancel();
    return super.close();
  }
}
