part of 'contract_list_bloc.dart';

sealed class ContractListEvent extends Equatable {
  const ContractListEvent();

  @override
  List<Object> get props => [];
}

final class ContractListSubscriptionRequested extends ContractListEvent {
  const ContractListSubscriptionRequested();
}
