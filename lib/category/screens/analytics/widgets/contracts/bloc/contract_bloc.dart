import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/analytics/widgets/contracts/contracts.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

part 'contract_event.dart';
part 'contract_state.dart';

class ContractBloc extends Bloc<ContractEvent, ContractState> {
  ContractBloc({
    required ContractRepository contractRepository,
  })  : _contractRepository = contractRepository,
        super(ContractState()) {
    on<ContractSubscriptionRequested>(_onSubscriptionRequested);
  }

  final ContractRepository _contractRepository;

  Future<void> _onSubscriptionRequested(
    ContractSubscriptionRequested event,
    Emitter<ContractState> emit,
  ) async {
    emit(state.copyWith(status: ContractStatus.loading));

    await emit.forEach<List<Contract>>(
      _contractRepository.activeContracts,
      onData: (contracts) => state.copyWith(
        status: ContractStatus.success,
        contracts: contracts,
      ),
      onError: (_, __) => state.copyWith(
        status: ContractStatus.failure,
      ),
    );
  }

  @override
  Future<void> close() {
    state.scrollController.dispose();
    return super.close();
  }
}
