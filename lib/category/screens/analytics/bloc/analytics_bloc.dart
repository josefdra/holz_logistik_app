import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/analytics/analytics.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({
    required ContractRepository contractRepository,
  })  : _contractRepository = contractRepository,
        super(const AnalyticsState()) {
    on<AnalyticsSubscriptionRequested>(_onSubscriptionRequested);
    on<AnalyticsContractDeleted>(_onContractDeleted);
    on<AnalyticsUndoDeletionRequested>(_onUndoDeletionRequested);
  }

  final ContractRepository _contractRepository;

  Future<void> _onSubscriptionRequested(
    AnalyticsSubscriptionRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    await emit.forEach<List<Contract>>(
      _contractRepository.contracts,
      onData: (contracts) => state.copyWith(
        status: AnalyticsStatus.success,
        contracts: contracts,
      ),
      onError: (_, __) => state.copyWith(
        status: AnalyticsStatus.failure,
      ),
    );
  }

  Future<void> _onContractDeleted(
    AnalyticsContractDeleted event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(lastDeletedContract: event.contract));
    await _contractRepository.deleteContract(event.contract.id);
  }

  Future<void> _onUndoDeletionRequested(
    AnalyticsUndoDeletionRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    assert(
      state.lastDeletedContract != null,
      'Last deleted contract can not be null.',
    );

    final contract = state.lastDeletedContract!;
    emit(state.copyWith());
    await _contractRepository.saveContract(contract);
  }
}
