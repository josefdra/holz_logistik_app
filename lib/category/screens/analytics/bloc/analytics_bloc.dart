import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/analytics/analytics.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({
    required ContractRepository contractRepository,
  })  : _contractRepository = contractRepository,
        super(AnalyticsState()) {
    on<AnalyticsSubscriptionRequested>(_onSubscriptionRequested);
  }

  final ContractRepository _contractRepository;

  Future<void> _onSubscriptionRequested(
    AnalyticsSubscriptionRequested event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    await emit.forEach<List<Contract>>(
      _contractRepository.activeContracts,
      onData: (contracts) => state.copyWith(
        status: AnalyticsStatus.success,
        contracts: contracts,
      ),
      onError: (_, __) => state.copyWith(
        status: AnalyticsStatus.failure,
      ),
    );
  }

  @override
  Future<void> close() {
    state.scrollController.dispose();
    return super.close();
  }
}
