import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'finished_contracts_event.dart';
part 'finished_contracts_state.dart';

class FinishedContractBloc
    extends Bloc<FinishedContractEvent, FinishedContractState> {
  FinishedContractBloc({
    required ContractRepository contractRepository,
  })  : _contractRepository = contractRepository,
        super(const FinishedContractState()) {
    on<FinishedContractSubscriptionRequested>(_onSubscriptionRequested);
  }

  final ContractRepository _contractRepository;
  final scrollController = ScrollController();

  Future<void> _onSubscriptionRequested(
    FinishedContractSubscriptionRequested event,
    Emitter<FinishedContractState> emit,
  ) async {
    emit(state.copyWith(status: FinishedContractStatus.loading));
    emit(state.copyWith(status: FinishedContractStatus.success));
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
