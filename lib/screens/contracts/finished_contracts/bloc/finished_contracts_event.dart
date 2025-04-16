part of 'finished_contracts_bloc.dart';

sealed class FinishedContractEvent extends Equatable {
  const FinishedContractEvent();

  @override
  List<Object> get props => [];
}

final class FinishedContractSubscriptionRequested
    extends FinishedContractEvent {
  const FinishedContractSubscriptionRequested();
}
