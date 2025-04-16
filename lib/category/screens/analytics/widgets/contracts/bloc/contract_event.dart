part of 'contract_bloc.dart';

sealed class ContractEvent extends Equatable {
  const ContractEvent();

  @override
  List<Object> get props => [];
}

final class ContractSubscriptionRequested extends ContractEvent {
  const ContractSubscriptionRequested();
}
