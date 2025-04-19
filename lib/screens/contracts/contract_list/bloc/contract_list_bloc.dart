import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/general/sort.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

part 'contract_list_event.dart';
part 'contract_list_state.dart';

class ContractListBloc extends Bloc<ContractListEvent, ContractListState> {
  ContractListBloc({
    required ContractRepository contractRepository,
  })  : _contractRepository = contractRepository,
        super(const ContractListState()) {
    on<ContractListSubscriptionRequested>(_onSubscriptionRequested);
  }

  final ContractRepository _contractRepository;
  final scrollController = ScrollController();

  Future<void> _onSubscriptionRequested(
    ContractListSubscriptionRequested event,
    Emitter<ContractListState> emit,
  ) async {
    emit(state.copyWith(status: ContractListStatus.loading));

    await emit.forEach<List<Contract>>(
      _contractRepository.activeContracts,
      onData: (contracts) => state.copyWith(
        status: ContractListStatus.success,
        contracts: contracts,
      ),
      onError: (_, __) => state.copyWith(
        status: ContractListStatus.failure,
      ),
    );
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
